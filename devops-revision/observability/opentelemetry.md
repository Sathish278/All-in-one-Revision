# OpenTelemetry (OTel) — Interview-ready Deep Dive

Purpose
- This file is a focused, interview-oriented OpenTelemetry reference for senior SRE/DevOps roles. It explains architecture, data model (traces, metrics, logs), SDK usage, Collector pipelines, exporters, sampling, operational considerations, security, and common interview questions with concise model answers.

Quick contract
- Inputs: instrumented application code (SDKs) or exporters that produce traces/metrics/logs.
- Outputs: telemetry data delivered to backends (Prometheus, Jaeger, Tempo, Loki, commercial APMs) via the OTel Collector or direct exporters.
- Success criteria: consistent semantic attributes, low-cost telemetry (controlled cardinality), reliable collection (collector HA), and actionable observability (useful traces and metrics).

Core concepts — short
- Data types: Traces (spans), Metrics (counters, gauges, histograms), Logs (structured/unstructured).
- Context propagation: W3C Trace Context (traceparent) + baggage to pass context across services.
- Resource attributes: describe service, host, region, environment (semantic conventions).
- OTLP: OpenTelemetry Protocol (gRPC/HTTP) used between SDK/Collector and Collector/backends.

Architecture & components
- SDKs: language-specific (Java, Python, Go, Node, .NET) for manual or auto-instrumentation. SDKs create spans and record metrics/logs.
- API vs SDK: API is the interface your code uses; SDK is the implementation that records and exports telemetry.
- Instrumentation libraries: instrument frameworks (e.g., Flask, Express, Spring) either manually or via auto-instrumentation agents.
- Collector: a vendor-agnostic telemetry pipeline (agent, gateway) that receives telemetry via OTLP/HTTP/GRPC, performs processing (batching, sampling, attributes enrichment), and exports to backends.
- Exporters: OTLP exporters or language-specific exporters to backends (Jaeger, Prometheus, Grafana Tempo, proprietary APMs).

OTel Collector — pipelines and components
- Receivers: accept telemetry (otlp, prometheus, jaeger, zipkin, statsd).
- Processors: perform transformations, batching, sampling, attribute anonymization, resource detection, tail-based sampling (advanced), metric aggregation.
- Exporters: push telemetry to backends (otlp exporters, prometheus, logging, jaeger)
- Extensions: health_check, zpages, authentication, observability for the collector itself.

Example Collector config (concise)

```yaml
receivers:
  otlp:
    protocols:
      grpc: {}
      http: {}
  prometheus:
    config:
      scrape_configs: []

processors:
  batch:
  resource:
    attributes:
      - key: service.version
        action: insert
        value: "1.0.0"

exporters:
  otlp/tempo:
    endpoint: tempo:4317
  prometheus:
    endpoint: ":9464"
  logging:
    logLevel: info

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [resource, batch]
      exporters: [otlp/tempo, logging]
    metrics:
      receivers: [otlp, prometheus]
      processors: [batch]
      exporters: [prometheus, logging]
```

SDK usage — examples (minimal, realistic)

Python (traces + metrics):

```python
from opentelemetry import trace, metrics
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter

trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)
span_exporter = OTLPSpanExporter(endpoint="http://otel-collector:4317", insecure=True)
trace.get_tracer_provider().add_span_processor(BatchSpanProcessor(span_exporter))

meter_provider = MeterProvider()
metrics.set_meter_provider(meter_provider)
meter = metrics.get_meter(__name__)
request_counter = meter.create_counter("http.server.requests")

with tracer.start_as_current_span("handle"):
    request_counter.add(1, {"route": "/home"})
```

Go (traces):

```go
import (
  "go.opentelemetry.io/otel"
  "go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
  sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

ctx := context.Background()
exp, _ := otlptracegrpc.New(ctx, otlptracegrpc.WithEndpoint("otel-collector:4317"), otlptracegrpc.WithInsecure())
tp := sdktrace.NewTracerProvider(sdktrace.WithBatcher(exp))
otel.SetTracerProvider(tp)
tr := otel.Tracer("example")
_, span := tr.Start(ctx, "operation")
defer span.End()
```

Node.js (auto-instrumentation example):

```bash
npm install --save @opentelemetry/sdk-node @opentelemetry/auto-instrumentations-node @opentelemetry/exporter-trace-otlp-grpc
```

```js
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-grpc');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({ url: 'http://otel-collector:4317' }),
  instrumentations: [getNodeAutoInstrumentations()],
});
sdk.start();
```

Metrics model & Prometheus
- OTel metrics API supports counters, gauges, histograms. When integrating with Prometheus, there are two common patterns:
  - Export metrics using the Prometheus client library and have Prometheus scrape the app.
  - Use OTel Collector's Prometheus exporter/receiver to convert OTel metrics into Prometheus format for scraping.

Sampling strategies
- Head-based (probabilistic) sampling: decide at span creation time (cheap, common).
- Tail-based sampling: buffer spans and decide after seeing more context (useful for rare-error detection but operationally complex and memory intensive).
- Adaptive sampling: dynamic sampling rates based on load or error conditions.

Semantic conventions and attributes
- Follow OTel semantic conventions for resource and span attributes (service.name, service.version, telemetry.sdk.name, http.method, db.system, net.peer.ip).
- Use consistent attribute naming to make queries and dashboards reliable across services.

Correlation: traces, metrics, and logs
- Correlate logs with traces using trace_id and span_id fields in logs; add them via logging instrumentation or by passing context/baggage to logger.
- Use metrics to drive SLOs and traces to diagnose root cause when SLOs breach.

Security and privacy
- Secure OTLP transport: use TLS and mTLS between SDKs/Collector and Collector/backends.
- Authentication: Collector can be configured with auth extensions (JWT, API keys) and act as a gateway.
- PII: avoid sending sensitive data (user identifiers) as attributes; consider hashing or redaction in processors.

Operational considerations
- Collector placement: agent (daemonset) vs gateway (centralized) — use agent for high cardinality per-host metrics and gateways for cross-cluster aggregation.
- Resource usage: batch and retry processors reduce network overhead; tune batch sizes and timeouts.
- Observability of observability: instrument the collector itself and use health checks and zpages.

Common pitfalls & how to avoid
- High cardinality from unbounded labels — restrict tag values, use attributes carefully.
- Double instrumentation leading to duplicate spans/metrics — standardize instrumentation approach and use auto-instrumentation cautiously.
- Misconfigured exporters causing data loss — add retries and dead-letter exporters for failed telemetry.

Vendor neutrality & migration
- Use OTel as a stable instrumentation layer; export to multiple backends simultaneously (split export) during migration.
- Use collector transformations to map attributes between vendor models.

Interview Q&A (practice answers)

Q: What is the difference between OpenTelemetry API and SDK?
A: The API defines the interface used by application code (start span, record metric). The SDK is the implementation that actually records and exports telemetry. Keeping code dependent only on the API enables swapping SDKs and exporters.

Q: How would you reduce telemetry costs while keeping useful observability?
A: Reduce cardinality, use sampling for traces (head-based for general load, tail-based for errors), limit metric cardinality, use histogram buckets wisely, and aggregate before export when possible.

Q: When do you use an agent (sidecar/daemonset) vs a gateway Collector?
A: Use agent/daemonset to capture host-local telemetry (node metrics, process metrics) and to reduce latency for telemetry export. Use a gateway Collector to centralize processing, enforce auth, and manage heavy exporters (billing/ingestion control).

Q: How do you correlate logs, traces, and metrics?
A: Ensure tracing context (trace_id, span_id) is injected into logs (structured) and as attributes on metrics where relevant. Use consistent resource attributes and semantic conventions across all telemetry.

Quick revision cheat-sheet
- Key terms: Span, Trace, Metric (counter/gauge/histogram), OTLP, Collector, Receiver/Processor/Exporter, Resource attributes.
- Headers for context propagation: `traceparent` (W3C), `tracestate`.
- Common receivers: otlp, prometheus, jaeger; common exporters: otlp, prometheus, jaeger, logging.

References & further reading
- OpenTelemetry docs: https://opentelemetry.io
- Collector contrib: https://github.com/open-telemetry/opentelemetry-collector-contrib
- Semantic conventions: https://github.com/open-telemetry/opentelemetry-specification/tree/main/semantic_conventions
