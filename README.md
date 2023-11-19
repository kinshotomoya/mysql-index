# mysql-index

## 概要

MySQL やpostgrSQLで作成できるインデックスの一つ

インメモリにおけるハッシュテーブルと同じようなデータ構造で構築される

## データ構造

キーバリューストア

インデックスを張るカラムの値をキーに、レコードが格納されているディスクへのポインタをバリューで持っている

## 特徴

完全一致検索で有効

カーディナリティが低いデータに対してはあまり効果がない。まあこれは他のインデックスでも言えることだが。ただカーディナリティが低くても偏りがあるなら有効

例えば、性別カラムで男女の比率が1:9で男を検索する場合、インデックスを張ることで元々フルスキャンするデータ量よりも1/10のデータ量での検索で済むから

キーが重複している場合は、バリューがリンクトリストによって結合するので重複が多いと、その分検索速度は遅くなる。ハッシュテーブルの特徴と同じ

## btreeやbtree+と何が違う？

btreeは範囲検索と前方一致検索でも効率的に検索できる

なぜならbtree+の場合は隣り合うリーフノード同士が連結されているから、a~hなどの別のリーフノードにあるレコードを効率よく検索できる

## MySQLで試してみた

- MySQLでは、ストレージエンジンとしてデフォルトでinnoDBを利用する
- しかし、innoDBではハッシュインデックスを作成できる
- Memoryストレージエンジンならハッシュインデックスを作成できる
- テーブル毎にストレージエンジンを指定できる

エンジンの確認

```sql
mysql> show engines;
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                        | Transactions | XA   | Savepoints |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| ndbcluster         | NO      | Clustered, fault-tolerant tables                               | NULL         | NULL | NULL       |
| FEDERATED          | NO      | Federated MySQL storage engine                                 | NULL         | NULL | NULL       |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables      | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys     | YES          | YES  | YES        |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                             | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                          | NO           | NO   | NO         |
| ndbinfo            | NO      | MySQL Cluster system information storage engine                | NULL         | NULL | NULL       |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                          | NO           | NO   | NO         |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) | NO           | NO   | NO         |
| CSV                | YES     | CSV storage engine                                             | NO           | NO   | NO         |
| ARCHIVE            | YES     | Archive storage engine                                         | NO           | NO   | NO         |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
11 rows in set (0.00 sec)

# indexの確認
mysql> show index from todo;
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name    | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| todo  |          0 | PRIMARY     |            1 | id          | NULL      |           0 |     NULL |   NULL |      | HASH       |         |               | YES     | NULL       |
| todo  |          1 | num_h_index |            1 | num_column  | NULL      |           0 |     NULL |   NULL |      | HASH       |         |               | YES     | NULL       |
| todo  |          1 | str_h_index |            1 | str_column  | NULL      |           0 |     NULL |   NULL |      | HASH       |         |               | YES     | NULL       |
| todo  |          1 | num_b_index |            1 | num_column  | A         |        NULL |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| todo  |          1 | str_b_index |            1 | str_column  | A         |        NULL |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
5 rows in set (0.01 sec)

# ハッシュインデックスを利用して値一致検索の実行計画見てみる
mysql> explain select * from todo use index(num_h_index) where num_column = 1;
+----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type | possible_keys | key         | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | todo  | NULL       | ref  | num_h_index   | num_h_index | 4       | const | 7030 |   100.00 | NULL  |
+----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)

# btreeインデックスを利用して値一致検索の実行計画見てみる
mysql> explain select * from todo use index(num_b_index) where num_column = 1;
+----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type | possible_keys | key         | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | todo  | NULL       | ref  | num_b_index   | num_b_index | 4       | const | 7642 |   100.00 | NULL  |
+----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)
```

↑rows（検索範囲の行数）は7000ちょっととほど同等

どのインデックスを利用するか指定しないと、ハッシュインデックスを利用している

```sql
mysql> explain select * from todo where num_column = 1;
+----+-------------+-------+------------+------+-------------------------+-------------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type | possible_keys           | key         | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+------+-------------------------+-------------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | todo  | NULL       | ref  | num_h_index,num_b_index | num_h_index | 4       | const | 7030 |   100.00 | NULL  |
+----+-------------+-------+------------+------+-------------------------+-------------+---------+-------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)
```

範囲検索の場合、btreeを利用している

```sql
mysql> explain select * from todo where num_column < 1;
+----+-------------+-------+------------+-------+-------------------------+-------------+---------+------+------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys           | key         | key_len | ref  | rows | filtered | Extra       |
+----+-------------+-------+------------+-------+-------------------------+-------------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | todo  | NULL       | range | num_h_index,num_b_index | num_b_index | 4       | NULL |    3 |   100.00 | Using where |
+----+-------------+-------+------------+-------+-------------------------+-------------+---------+------+------+----------+-------------+
1 row in set, 1 warning (0.00 sec)
```

文字列前方一致検索の場合、btreeを利用

```sql
mysql> explain select * from todo where str_column like "a%";
+----+-------------+-------+------------+-------+-------------------------+-------------+---------+------+------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys           | key         | key_len | ref  | rows | filtered | Extra       |
+----+-------------+-------+------------+-------+-------------------------+-------------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | todo  | NULL       | range | str_h_index,str_b_index | str_b_index | 40      | NULL | 5001 |   100.00 | Using where |
+----+-------------+-------+------------+-------+-------------------------+-------------+---------+------+------+----------+-------------+
1 row in set, 1 warning (0.01 sec)
```

後方一致検索の場合は、フルスキャン

btreeデータ構造の仕組み上、後方検索は効率悪い

```sql
mysql> explain select * from todo where str_column like "%a";
+----+-------------+-------+------------+------+---------------+------+---------+------+-------+----------+-------------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows  | filtered | Extra       |
+----+-------------+-------+------------+------+---------------+------+---------+------+-------+----------+-------------+
|  1 | SIMPLE      | todo  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 70308 |    11.11 | Using where |
+----+-------------+-------+------------+------+---------------+------+---------+------+-------+----------+-------------+
1 row in set, 1 warning (0.01 sec)
```

実行計画を実施したクエリのプロファイルをしてみる

```bash
for _ in `seq 1 10`; do
mysql -h 127.0.0.1 -u root -D indextest -e "\
SET profiling = 1; \
SELECT * FROM todo use index(num_h_index) WHERE num_column = 1; \
SELECT * FROM todo use index(num_b_index) WHERE num_column = 1; \
SELECT * FROM todo use index(num_h_index) WHERE num_column BETWEEN 1 and 5; \
SELECT * FROM todo use index(num_b_index) WHERE num_column BETWEEN 1 and 5; \
SELECT * FROM todo WHERE str_column like 'a%'; \
SELECT * FROM todo WHERE str_column like '%a';SHOW PROFILES; \
" | tail -n 6 >> result
done 

for i in `seq 1 6`; do
cat result | grep ^$i | awk '{ sum+=$2; cnt++ } END { print sum / cnt }'
done
```

結果

- 値一致検索に関しては、若干ハッシュインデックスを用いた方が速度はやい
- 範囲検索では、btreeの方が圧倒的に早い
- btree検索では、後方一致検索はめっちゃ遅い

```bash
0.00400503 #SELECT * FROM todo use index(num_h_index) WHERE num_column = 1; \
0.00487661 #SELECT * FROM todo use index(num_b_index) WHERE num_column = 1; \
0.0203937 #SELECT * FROM todo use index(num_h_index) WHERE num_column BETWEEN 1 and 5; \
0.0108807 #SELECT * FROM todo use index(num_b_index) WHERE num_column BETWEEN 1 and 5; \
0.00950659 #SELECT * FROM todo WHERE str_column like 'a%'; \
0.0118348 #SELECT * FROM todo WHERE str_column like '%a'

```

## 参考

https://dev.mysql.com/doc/refman/8.0/ja/index-btree-hash.html

https://qiita.com/K-jun/items/a86a3829cf796b6d5ad8