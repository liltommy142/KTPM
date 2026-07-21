# ArchLens Modules

## microservices-demo/kustomize/components/shopping-assistant/scripts/generate_sql_from_products.py
- Language: python
- Depends on:
  - json
- Depended on by:
  - none
- Unresolved imports:
  - json

## microservices-demo/src/currencyservice/client.js
- Language: javascript
- Depends on:
  - @google-cloud/trace-agent
  - grpc
  - path
  - pino
- Depended on by:
  - none
- Unresolved imports:
  - @google-cloud/trace-agent
  - path
  - grpc
  - pino

## microservices-demo/src/currencyservice/server.js
- Language: javascript
- Depends on:
  - ./data/currency_conversion.json
  - @google-cloud/profiler
  - @grpc/grpc-js
  - @grpc/proto-loader
  - @opentelemetry/exporter-otlp-grpc
  - @opentelemetry/instrumentation
  - @opentelemetry/instrumentation-grpc
  - @opentelemetry/resources
  - @opentelemetry/sdk-node
  - @opentelemetry/semantic-conventions
  - path
  - pino
- Depended on by:
  - none
- Unresolved imports:
  - pino
  - @google-cloud/profiler
  - @opentelemetry/instrumentation-grpc
  - @opentelemetry/instrumentation
  - @opentelemetry/resources
  - @opentelemetry/semantic-conventions
  - @opentelemetry/sdk-node
  - @opentelemetry/exporter-otlp-grpc
  - path
  - @grpc/grpc-js
  - @grpc/proto-loader
  - ./data/currency_conversion.json

## microservices-demo/src/emailservice/demo_pb2_grpc.py
- Language: python
- Depends on:
  - demo_pb2
  - grpc
- Depended on by:
  - none
- Unresolved imports:
  - grpc
  - demo_pb2

## microservices-demo/src/emailservice/demo_pb2.py
- Language: python
- Depends on:
  - google.protobuf.descriptor
  - google.protobuf.descriptor_pool
  - google.protobuf.internal.builder
  - google.protobuf.symbol_database
- Depended on by:
  - none
- Unresolved imports:
  - google.protobuf.internal.builder
  - google.protobuf.descriptor
  - google.protobuf.descriptor_pool
  - google.protobuf.symbol_database

## microservices-demo/src/emailservice/email_client.py
- Language: python
- Depends on:
  - demo_pb2
  - demo_pb2_grpc
  - grpc
  - logger.getJSONLogger
- Depended on by:
  - none
- Unresolved imports:
  - grpc
  - demo_pb2
  - demo_pb2_grpc
  - logger.getJSONLogger

## microservices-demo/src/emailservice/email_server.py
- Language: python
- Depends on:
  - argparse
  - concurrent.futures
  - demo_pb2
  - demo_pb2_grpc
  - google.api_core.exceptions.GoogleAPICallError
  - google.auth.exceptions.DefaultCredentialsError
  - grpc
  - grpc_health.v1.health_pb2
  - grpc_health.v1.health_pb2_grpc
  - jinja2.Environment
  - jinja2.FileSystemLoader
  - jinja2.TemplateError
  - jinja2.select_autoescape
  - logger.getJSONLogger
  - opentelemetry.exporter.otlp.proto.grpc.trace_exporter.OTLPSpanExporter
  - opentelemetry.instrumentation.grpc.GrpcInstrumentorServer
  - opentelemetry.sdk.trace.TracerProvider
  - opentelemetry.sdk.trace.export.BatchSpanProcessor
  - opentelemetry.trace
  - os
  - sys
  - time
  - traceback
- Depended on by:
  - none
- Unresolved imports:
  - concurrent.futures
  - argparse
  - os
  - sys
  - time
  - grpc
  - traceback
  - jinja2.Environment
  - jinja2.FileSystemLoader
  - jinja2.select_autoescape
  - jinja2.TemplateError
  - google.api_core.exceptions.GoogleAPICallError
  - google.auth.exceptions.DefaultCredentialsError
  - demo_pb2
  - demo_pb2_grpc
  - grpc_health.v1.health_pb2
  - grpc_health.v1.health_pb2_grpc
  - opentelemetry.trace
  - opentelemetry.instrumentation.grpc.GrpcInstrumentorServer
  - opentelemetry.sdk.trace.TracerProvider
  - opentelemetry.sdk.trace.export.BatchSpanProcessor
  - opentelemetry.exporter.otlp.proto.grpc.trace_exporter.OTLPSpanExporter
  - logger.getJSONLogger

## microservices-demo/src/emailservice/logger.py
- Language: python
- Depends on:
  - logging
  - pythonjsonlogger.jsonlogger
  - sys
- Depended on by:
  - none
- Unresolved imports:
  - logging
  - sys
  - pythonjsonlogger.jsonlogger

## microservices-demo/src/loadgenerator/locustfile.py
- Language: python
- Depends on:
  - datetime
  - faker.Faker
  - locust.FastHttpUser
  - locust.TaskSet
  - locust.between
  - random
- Depended on by:
  - none
- Unresolved imports:
  - random
  - locust.FastHttpUser
  - locust.TaskSet
  - locust.between
  - faker.Faker
  - datetime

## microservices-demo/src/paymentservice/charge.js
- Language: javascript
- Depends on:
  - pino
  - simple-card-validator
  - uuid
- Depended on by:
  - microservices-demo/src/paymentservice/server.js
- Unresolved imports:
  - simple-card-validator
  - uuid
  - pino

## microservices-demo/src/paymentservice/index.js
- Language: javascript
- Depends on:
  - @google-cloud/profiler
  - @opentelemetry/exporter-otlp-grpc
  - @opentelemetry/instrumentation
  - @opentelemetry/instrumentation-grpc
  - @opentelemetry/resources
  - @opentelemetry/sdk-node
  - @opentelemetry/semantic-conventions
  - microservices-demo/src/paymentservice/logger.js
  - microservices-demo/src/paymentservice/server.js
  - path
- Depended on by:
  - none
- Unresolved imports:
  - @google-cloud/profiler
  - @opentelemetry/resources
  - @opentelemetry/semantic-conventions
  - @opentelemetry/instrumentation-grpc
  - @opentelemetry/instrumentation
  - @opentelemetry/sdk-node
  - @opentelemetry/exporter-otlp-grpc
  - path

## microservices-demo/src/paymentservice/logger.js
- Language: javascript
- Depends on:
  - pino
- Depended on by:
  - microservices-demo/src/paymentservice/index.js
  - microservices-demo/src/paymentservice/server.js
- Unresolved imports:
  - pino

## microservices-demo/src/paymentservice/server.js
- Language: javascript
- Depends on:
  - @grpc/grpc-js
  - @grpc/proto-loader
  - microservices-demo/src/paymentservice/charge.js
  - microservices-demo/src/paymentservice/logger.js
  - path
- Depended on by:
  - microservices-demo/src/paymentservice/index.js
- Unresolved imports:
  - path
  - @grpc/grpc-js
  - @grpc/proto-loader

## microservices-demo/src/recommendationservice/client.py
- Language: python
- Depends on:
  - demo_pb2
  - demo_pb2_grpc
  - grpc
  - logger.getJSONLogger
  - sys
- Depended on by:
  - none
- Unresolved imports:
  - sys
  - grpc
  - demo_pb2
  - demo_pb2_grpc
  - logger.getJSONLogger

## microservices-demo/src/recommendationservice/demo_pb2_grpc.py
- Language: python
- Depends on:
  - demo_pb2
  - grpc
- Depended on by:
  - none
- Unresolved imports:
  - grpc
  - demo_pb2

## microservices-demo/src/recommendationservice/demo_pb2.py
- Language: python
- Depends on:
  - google.protobuf.descriptor
  - google.protobuf.descriptor_pool
  - google.protobuf.internal.builder
  - google.protobuf.symbol_database
- Depended on by:
  - none
- Unresolved imports:
  - google.protobuf.internal.builder
  - google.protobuf.descriptor
  - google.protobuf.descriptor_pool
  - google.protobuf.symbol_database

## microservices-demo/src/recommendationservice/logger.py
- Language: python
- Depends on:
  - logging
  - pythonjsonlogger.jsonlogger
  - sys
- Depended on by:
  - none
- Unresolved imports:
  - logging
  - sys
  - pythonjsonlogger.jsonlogger

## microservices-demo/src/recommendationservice/recommendation_server.py
- Language: python
- Depends on:
  - concurrent.futures
  - demo_pb2
  - demo_pb2_grpc
  - google.auth.exceptions.DefaultCredentialsError
  - grpc
  - grpc_health.v1.health_pb2
  - grpc_health.v1.health_pb2_grpc
  - logger.getJSONLogger
  - opentelemetry.exporter.otlp.proto.grpc.trace_exporter.OTLPSpanExporter
  - opentelemetry.instrumentation.grpc.GrpcInstrumentorClient
  - opentelemetry.instrumentation.grpc.GrpcInstrumentorServer
  - opentelemetry.sdk.trace.TracerProvider
  - opentelemetry.sdk.trace.export.BatchSpanProcessor
  - opentelemetry.trace
  - os
  - random
  - time
  - traceback
- Depended on by:
  - none
- Unresolved imports:
  - os
  - random
  - time
  - traceback
  - concurrent.futures
  - google.auth.exceptions.DefaultCredentialsError
  - grpc
  - demo_pb2
  - demo_pb2_grpc
  - grpc_health.v1.health_pb2
  - grpc_health.v1.health_pb2_grpc
  - opentelemetry.trace
  - opentelemetry.instrumentation.grpc.GrpcInstrumentorClient
  - opentelemetry.instrumentation.grpc.GrpcInstrumentorServer
  - opentelemetry.sdk.trace.TracerProvider
  - opentelemetry.sdk.trace.export.BatchSpanProcessor
  - opentelemetry.exporter.otlp.proto.grpc.trace_exporter.OTLPSpanExporter
  - logger.getJSONLogger

## microservices-demo/src/shoppingassistantservice/shoppingassistantservice.py
- Language: python
- Depends on:
  - flask.Flask
  - flask.request
  - google.cloud.secretmanager_v1
  - langchain_core.messages.HumanMessage
  - langchain_google_alloydb_pg.AlloyDBEngine
  - langchain_google_alloydb_pg.AlloyDBVectorStore
  - langchain_google_genai.ChatGoogleGenerativeAI
  - langchain_google_genai.GoogleGenerativeAIEmbeddings
  - os
  - urllib.parse.unquote
- Depended on by:
  - none
- Unresolved imports:
  - os
  - google.cloud.secretmanager_v1
  - urllib.parse.unquote
  - langchain_core.messages.HumanMessage
  - langchain_google_genai.ChatGoogleGenerativeAI
  - langchain_google_genai.GoogleGenerativeAIEmbeddings
  - flask.Flask
  - flask.request
  - langchain_google_alloydb_pg.AlloyDBEngine
  - langchain_google_alloydb_pg.AlloyDBVectorStore
