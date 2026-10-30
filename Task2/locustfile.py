# Сценарий нагрузки Locust для проверки динамического масштабирования:
# пользователи с интервалом 1-5 секунд запрашивают идентификатор пода (GET /).
from locust import HttpUser, between, task


class WebsiteUser(HttpUser):
    wait_time = between(1, 5)

    @task
    def index(self):
        self.client.get("/")