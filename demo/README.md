# Demo

```sh
RUN mysql -uroot -ppassword -e "CREATE DATABASE chevereto;"
RUN mysql -uroot -ppassword -e "CREATE USER 'chevereto' IDENTIFIED BY 'user_database_password';"
RUN mysql -uroot -ppassword -e "GRANT ALL ON chevereto.* TO 'chevereto' IDENTIFIED BY 'user_database_password';"
```

```sh
docker exec -itd chv-demo \
    curl -X POST http://localhost:80/install \
    --data "username=demo" \
    --data "email=demo@chevereto.loc" \
    --data "password=password" \
    --data "email_from_email=demo@chevereto.loc" \
    --data "email_incoming_email=demo@chevereto.loc" \
    --data "website_mode=community"
```
