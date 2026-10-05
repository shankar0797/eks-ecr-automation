from flask import Flask, request, g
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import os
import time


app = Flask(__name__)


# --------------------------------------------------
# Prometheus Metrics
# --------------------------------------------------

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total number of HTTP requests",
    ["method", "endpoint", "status"]
)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency in seconds",
    ["method", "endpoint"]
)


# --------------------------------------------------
# Request Tracking
# --------------------------------------------------

@app.before_request
def before_request():
    g.start_time = time.perf_counter()


@app.after_request
def after_request(response):

    duration = time.perf_counter() - g.start_time

    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.path,
        status=response.status_code
    ).inc()

    REQUEST_LATENCY.labels(
        method=request.method,
        endpoint=request.path
    ).observe(duration)

    return response


# --------------------------------------------------
# Application Endpoints
# --------------------------------------------------

@app.route("/")
def home():
    return {
        "message": "EKS ECR Automation Demo",
        "version": os.getenv("APP_VERSION", "local")
    }


@app.route("/health")
def health():
    return {
        "status": "healthy"
    }


# --------------------------------------------------
# Prometheus Metrics Endpoint
# --------------------------------------------------

@app.route("/metrics")
def metrics():

    return generate_latest(), 200, {
        "Content-Type": CONTENT_TYPE_LATEST
    }


# --------------------------------------------------
# Application Start
# --------------------------------------------------

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
