@echo off

cd schema

set out="../out/schema.sql"
copy /b *.sql %out%

echo /* This file is generated >> %out%
date /t >> %out%
time /t >> %out%
echo */ >> %out%

:::::::::::::::::::::::::::::::::::::::::::::::

cd ../test

set out="../out/tests.sql"
copy /b *.sql %out%

echo /* This file is generated >> %out%
date /t >> %out%
time /t >> %out%
echo */ >> %out%
