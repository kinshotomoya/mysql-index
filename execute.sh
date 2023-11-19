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