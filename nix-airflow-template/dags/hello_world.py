import uuid
import logging
from datetime import timedelta, datetime
from typing import NamedTuple, Any

from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago

logger = logging.getLogger(__name__)

ORG = 'MyOrg'

NEVER = datetime.now() + timedelta(days=365 * 1000)

class Defaults(NamedTuple):
    owner: str = ORG
    depends_on_past: bool = False
    retries: int = 1
    start_date: datetime = days_ago(1)
    end_date: datetime = NEVER
    retry_delay: timedelta = timedelta(minutes=5)


DEFAULTS = Defaults()


def combine(**ctx: Any) -> str:
    hello_value, sep_value = ctx['task_instance'].xcom_pull(task_ids=('hello', 'separator'))
    return f'{hello_value}{sep_value}World!'

def hello() -> str:
    return 'Hello'

def sep() -> str:
    return ' '

with DAG(
    'HelloWorld',
    default_args=DEFAULTS._asdict(),
    description='A simple example DAG',
) as dag:
    t1 = PythonOperator(task_id="hello", python_callable=hello)
    t2 = PythonOperator(task_id="separator", python_callable=sep)
    t3 = PythonOperator(task_id="world", python_callable=combine, provide_context=True)

t1 >> t2 >> t3
