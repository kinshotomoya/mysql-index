create database indextest;
use indextest;
drop table if exists todo;
create table todo(
    id int not null auto_increment,
    num_column int not null,
    str_column char(10) not null,
    primary key (id) 
) engine memory;

# Hash Index
create index num_h_index using hash on todo (num_column);
create index str_h_index using hash on todo (str_column);
# B-Tree Index
create index num_b_index using btree on todo (num_column);
create index str_b_index using btree on todo (str_column);