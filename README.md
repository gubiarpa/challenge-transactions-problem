# Solución

A continuación, se presentan los casos de uso de la solución, con detalles específicos sobre su diseño, estrategias y herramientas utilizadas.

- [Caso 1](#caso-1): Solución para la transacción de desembolsos con procesos online y batch
- [Caso 2](#caso-2): Solución para el proceso masivo de pagos automático

## Caso 1

### 1. Diseño de la Solución (Online y Batch)

- Para los procesos **online**, utilizaría una arquitectura basada en **microservicios**, lo que permite manejar la transacción de desembolsos en tiempo real, garantizando alta disponibilidad y escalabilidad.
- Para los procesos **batch**, emplearía servicios de procesamiento masivo, como **Azure Data Factory** o **Windows Services**, que permiten manejar grandes volúmenes de datos sin afectar el rendimiento de las operaciones online.
- El proceso batch consolidará grandes volúmenes de transacciones y realizará cálculos en masa, mientras que el proceso online manejará solicitudes en tiempo real.


![Diagrama de la Solución](/Caso-1.svg)
Esto lo modelé usando Excalidraw.io :)

### 2. Multicanalidad y Seguridad

- **Multicanalidad**: Usar una **API Gateway** para gestionar las solicitudes de diferentes canales como aplicaciones móviles, web y sistemas de terceros, brindando flexibilidad y control.
- **Seguridad**: Implementar mecanismos de **autenticación y autorización** con **OAuth 2.0** o **OpenID Connect** para las APIs. Además, garantizar la **encriptación de datos** en tránsito (TLS) y en reposo (AES-256).

### 3. Número de Capas

Se utilizaría una arquitectura de **tres capas**:

1. **Capa de Presentación**: Maneja las interfaces de usuario y la multicanalidad. Frameworks como **React** para web y **React Native** para aplicaciones móviles son ideales para este propósito.
2. **Capa de Aplicación**: Microservicios en **ASP.NET Core** que manejan la lógica de negocio, incluyendo transacciones de desembolso y procesos batch.
3. **Capa de Datos**: Base de datos relacional **SQL Server** para transacciones críticas y **Cosmos DB** para datos no transaccionales como logs o auditorías.

### 4. Herramientas por Capa y Justificación

- **Capa de Presentación**:
  - **React** o **React Native**: Ofrecen flexibilidad para el desarrollo de aplicaciones web y móviles. React y React Navite son ideales para interfaces de usuario dinámicas y rápidas.
- **Capa de Aplicación**:
  - **ASP.NET Core**: Robusto y escalable, ideal para manejar procesos online y batch, con soporte para alta concurrencia y seguridad.
  - **Azure Service Bus** o **RabbitMQ**: Para la comunicación entre microservicios de manera desacoplada y confiable.
  - **Redis Cache**: Para mejorar tiempos de respuesta en procesos concurrentes mediante almacenamiento de resultados intermedios.
- **Capa de Datos**:
  - **SQL Server**: Ideal para transacciones ACID que garantizan integridad en los desembolsos.
  - **Cosmos DB**: Base de datos NoSQL para manejar datos no transaccionales a gran escala, con alta disponibilidad y replicación global.

### 5. Lenguaje de Programación por Capa y Justificación

- **Capa de Presentación**:
  - **JavaScript/TypeScript**: Para aplicaciones web con **React** y en aplicaciones móviles con **React Native**.
- **Capa de Aplicación**:
  - **C#** con **ASP.NET Core**: Ofrece alta performance, seguridad y soporte nativo para microservicios y aplicaciones cloud.
- **Capa de Datos**:
  - **T-SQL**: Para interacciones con **SQL Server**.
  - **Cosmos DB SDK**: Para interacciones con bases de datos NoSQL.

### Consideraciones Adicionales

- **Alta concurrencia**: Los **microservicios** y **caching** aseguran que las solicitudes concurrentes no afecten negativamente el rendimiento.
- **Escalabilidad**: Utilizando servicios en la nube como **Azure Kubernetes Service (AKS)** o **Docker Swarm**, los microservicios pueden escalar automáticamente.
- **Monitoreo y trazabilidad**: Implementar **Azure Application Insights** para monitorear el rendimiento y detectar problemas, garantizando tiempos de respuesta óptimos.

### Resumen

Esta solución distribuye las responsabilidades entre los procesos online y batch, asegurando estabilidad, escalabilidad y seguridad, mientras se soporta la alta concurrencia de decenas de miles de transacciones diarias.

---

## Caso 2

## 1. Planteamiento de la Solución

Para incorporar el proceso masivo de pagos de manera automática, se implementará un sistema basado en **microservicios** que procese eficientemente los pagos, aplique descuentos y gestione devoluciones. Este sistema estará optimizado para manejar un alto volumen de transacciones, especialmente durante los días pico (hasta 1 millón de pagos).

![Diagrama de la Solución](/Caso-2.svg)
Esto lo modelé usando Excalidraw.io :)

## 2. Estrategia y Herramientas a Utilizar

- **Microservicios en .NET 8**: Cada función (pagos, descuentos, devoluciones, reportes) será implementada como un microservicio independiente. Esto permitirá la escalabilidad y separación de responsabilidades.
- **Azure Functions** o **Windows Services**: Para ejecutar el proceso masivo semanalmente (los viernes), automatizando la carga de datos y el procesamiento de pagos.
- **Azure Service Bus** o **RabbitMQ**: Para la comunicación y gestión de mensajes entre los microservicios. Esto asegura que las transacciones sean procesadas de forma asíncrona y sin pérdidas de información.
- **Redis Cache**: Para mejorar el rendimiento, almacenando temporalmente los cálculos intermedios y los resultados de pagos frecuentes.
- **Azure Data Factory** o **SSIS**: Para la carga masiva de datos desde las diversas fuentes a la base de datos principal, optimizando el tiempo de procesamiento de las entradas.

## 3. Diseño de la Base de Datos en SQL

La base de datos estará diseñada en **SQL Server** y constará de las siguientes tablas clave:

- **Pago**:
  - `IdPago`, `Monto`, `IdEstado` (procesado, no procesado, devolución).
- **EstadoPago**
  - `IdPago`, `Estado` (procesado, no procesado, devolución).
- **Descuento**:
  - `IdPago`, `PorcentajeDescuento` (decimal), `ValorVariable` (con base en las 10 variables proporcionadas).
- **Devolucion**:
  - `IdDevolucion`, `IdPago`, `MontoExcedente`, `Fecha`.
- **Historial**:

  - Contendrá los datos históricos de pagos y variables, necesarios para el cálculo de descuentos, con datos de los últimos 5 años.

  El diseño incluirá **índices** en las columnas más consultadas (`IdPago`, `IdEstado`, `Monto`) para optimizar las consultas y mejorar el rendimiento.
  Se debe analizar a profundidad el uso de índices en las consultas, ya que el volumen de transacciones puede aumentar significativamente durante los días pico, y esto puede desencadenar un incremento en el tiempo de respuesta.

## 4. Estrategias para Garantizar el Máximo Rendimiento de la Base de Datos

- **Particionado de tablas**: Dado el alto volumen de transacciones, se implementará el particionado de las tablas de pagos y devoluciones, para mejorar la consulta y la carga de datos.
- **Índices optimizados**: Crear **índices compuestos** en las columnas más consultadas, como `IdPago`, `Fecha`, y `Estado`, para mejorar la velocidad de las consultas, especialmente durante los días pico.
- **Caché**: Utilizar **Redis Cache** para almacenar temporalmente datos frecuentes o resultados intermedios, reduciendo la carga sobre la base de datos.
- **Ejecución por lotes (batch)**: El proceso de pagos se ejecutará en lotes pequeños dentro del proceso masivo, para evitar sobrecargar la base de datos.
- **Transacciones distribuidas**: Asegurar la integridad de los pagos, descuentos y devoluciones utilizando **transacciones distribuidas**, garantizando que todas las operaciones se completen de manera exitosa o se reviertan si ocurre un fallo.

## 5. Monitoreo y Reportes

- **Azure Application Insights** y **SQL Server Profiler**: Para monitorear el rendimiento de los procesos y la base de datos en tiempo real.
- **Generación de reportes**:

  - Reporte de **Pagos Procesados**: Incluyendo los detalles de los pagos exitosos y fallidos.
  - Reporte de **Devoluciones**: Que muestre los montos excedentes devueltos.
  - Reporte de **Descuentos**: Detallando los pagos que recibieron descuentos y las variables que aplicaron.

  Los reportes se generarán automáticamente al final de cada proceso masivo y se almacenarán en formato **CSV** o **Excel** para ser consultados posteriormente.

## 6. Seguridad

- **Autenticación y Autorización**: Uso de **Azure Active Directory (AAD)** con OAuth 2.0 para validar usuarios y servicios, garantizando acceso solo a roles autorizados.
- **Cifrado**: Datos en tránsito cifrados con **TLS 1.2+**; datos en reposo mediante **Transparent Data Encryption (TDE)** y gestión de claves en **Azure Key Vault**.
- **Gestión de Accesos**: Control de acceso basado en roles (**RBAC**) en servicios y base de datos, asegurando permisos mínimos necesarios.
- **Protección DDoS**: Implementación de **Azure DDoS Protection** para defender los endpoints.
- **Auditoría**: Registros detallados con **Azure Monitor** y **Application Insights** para trazabilidad y detección de anomalías.
- **Backups**: Políticas de **backup** y recuperación para proteger los datos críticos.

Esto asegura la seguridad, integridad y disponibilidad del sistema de pagos.

## 7. Diagrama Entidad-Relación

![Modelado de Datos de la Solución](/Entity-Relation.svg)
Esto lo modelé usando dbdiagram.io :)

## Resumen

Esta solución maneja eficientemente el proceso masivo de pagos mediante una arquitectura de microservicios, integrando componentes que aseguran el procesamiento rápido y confiable de hasta un millón de transacciones. La base de datos está optimizada para soportar alta concurrencia y volumen, mientras que las herramientas de monitoreo y reportes garantizan la visibilidad completa del proceso.
