FROM python:3.9-slim-bookworm

WORKDIR /opt/adventureworks

# You can set default environments here, but it is recommended these to be set in ECS
ENV DBT_HOST "hostname.of.database"
ENV DBT_USER "postgres"
# ENV DBT_PASSWORD "DO NOT SET HERE!"
# YOU SHOULD NOT HARDCODE PASSWORDS EVER, make use of secrets instead https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions

COPY adventureworks .
COPY requirements.txt .

RUN pip install -r ./requirements.txt

CMD = [ "sh", "-c", "dbt deps && dbt ls"]
