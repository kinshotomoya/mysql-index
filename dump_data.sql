INSERT INTO todo
    (num_column, str_column)
VALUES
    (CEIL(RAND() * 10), CONCAT(SUBSTRING(MD5(RAND()), 1, 10))),
    (CEIL(RAND() * 10), CONCAT(SUBSTRING(MD5(RAND()), 1, 10))),
    (CEIL(RAND() * 10), CONCAT(SUBSTRING(MD5(RAND()), 1, 10))),
    (CEIL(RAND() * 10), CONCAT(SUBSTRING(MD5(RAND()), 1, 10))),
    (CEIL(RAND() * 10), CONCAT(SUBSTRING(MD5(RAND()), 1, 10))),
    (CEIL(RAND() * 10), CONCAT(SUBSTRING(MD5(RAND()), 1, 10))),
    (CEIL(RAND() * 10), CONCAT(SUBSTRING(MD5(RAND()), 1, 10))),
    (CEIL(RAND() * 10), CONCAT(SUBSTRING(MD5(RAND()), 1, 10))),
    (CEIL(RAND() * 10), CONCAT(SUBSTRING(MD5(RAND()), 1, 10))),
    (CEIL(RAND() * 10), CONCAT(SUBSTRING(MD5(RAND()), 1, 10)));

INSERT INTO todo
    (num_column, str_column)
SELECT CEIL(RAND() * 10), CONCAT(SUBSTRING(MD5(RAND()), 1, 10))
from todo cross join todo as todo2
where todo2.id between 1 and 9;
INSERT INTO todo
    (num_column, str_column)
SELECT CEIL(RAND() * 10), CONCAT(SUBSTRING(MD5(RAND()), 1, 10))
from todo cross join todo as todo2
where todo2.id between 1 and 9;
INSERT INTO todo
    (num_column, str_column)
SELECT CEIL(RAND() * 10), CONCAT(SUBSTRING(MD5(RAND()), 1, 10))
from todo cross join todo as todo2
where todo2.id between 1 and 9;
INSERT INTO todo
    (num_column, str_column)
SELECT CEIL(RAND() * 10), CONCAT(SUBSTRING(MD5(RAND()), 1, 10))
from todo cross join todo as todo2
where todo2.id between 1 and 9;
