```markdown
# OpenTelemetry (OTel) — interview-ready revision

> Summary: OpenTelemetry fundamentals — SDKs, Collector pipelines, exporters, sampling, and correlating traces/metrics/logs.
>
> How to use: instrument a sample service with an OTel SDK, send data to the Collector, and export to Prometheus/Tempo/Grafana for end-to-end visibility.

1) Core pieces
- SDKs (language-specific), Collector (agent/collector), exporters (Prometheus, OTLP, Jaeger/Tempo), and propagators.

2) Traces vs Metrics vs Logs
- Traces: request flows & spans; Metrics: aggregated numeric series; Logs: unstructured events — correlate via trace_id or service labels.

3) Collector pipeline (example)
- Receivers: otlp
- Processors: batch, resource, memory_limiter
- Exporters: prometheus, tempo, logging

4) Sampling
- Head-based vs tail-based sampling; choose strategy to reduce ingestion costs while preserving fidelity for critical transactions.

5) Instrumentation best practices
- Add meaningful span names, avoid high-cardinality attributes, and capture error/status codes and durations.

6) Interview Q&A
- Q: When use tail-based sampling? A: When you need to sample based on downstream behavior (e.g., only trace requests that result in errors).

--

I can add a minimal Collector config, a sample instrumentation snippet (Go/Python), and a dashboard example for traces→logs→metrics correlation.
```
