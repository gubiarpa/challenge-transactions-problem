-- Partición de fechas para la tabla Pagos
CREATE PARTITION FUNCTION pfPagos
  (DATETIME)
AS RANGE RIGHT FOR VALUES
  ('2021-01-01', '2022-01-01', '2023-01-01', '2024-01-01', '2025-01-01', '2026-01-01');	

CREATE PARTITION SCHEME psPagos
AS PARTITION pfPagos ALL TO ([PRIMARY]);

-- Tabla EstadoPago para almacenar los posibles estados de un pago
CREATE TABLE EstadoPago (
  IdEstado INT IDENTITY(1, 1) PRIMARY KEY,
  DescripcionEstado VARCHAR(100) NOT NULL
);

-- Tabla Pagos para almacenar los pagos
CREATE TABLE Pagos (
  IdPago INT IDENTITY(1, 1) PRIMARY KEY,
  Monto DECIMAL(18, 2) NOT NULL,
  IdEstado INT NOT NULL, -- FK a EstadoPago
  FechaPago DATETIME NOT NULL,
  IdCliente INT NOT NULL,
  FOREIGN KEY (IdEstado) REFERENCES EstadoPago(IdEstado)
) ON
  psPagos(FechaPago);

-- Índice compuesto para mejorar la consulta por IdEstado y FechaPago
CREATE INDEX IX_Pagos_IdEstado_FechaPago ON Pagos (IdEstado, FechaPago);

-- Tabla Historial
CREATE TABLE Historial (
    IdHistorial INT IDENTITY(1,1) PRIMARY KEY,
    IdPago INT NOT NULL,
    ValorVariable DECIMAL(18, 2) NOT NULL,
    FechaRegistro DATETIME NOT NULL,
    FOREIGN KEY (IdPago) REFERENCES Pagos(IdPago)
);

-- Insertamos los estados de pago
INSERT INTO EstadoPago
  (DescripcionEstado)
VALUES
  ('procesado'),
  ('no procesado'),
  ('devolución');

-- Insertar algunos pagos
INSERT INTO Pagos
  (Monto, IdEstado, FechaPago, IdCliente)
VALUES
  (100.00, 1, '2022-05-15', 1),
  (200.00, 2, '2023-08-22', 2),
  (300.00, 3, '2024-03-12', 3);


-- Consultar los datos con un JOIN para ver los estados
SELECT
  p.IdPago,
  p.Monto,
  ep.DescripcionEstado,
  p.FechaPago
FROM
  Pagos p INNER JOIN
  EstadoPago ep ON
    p.IdEstado = ep.IdEstado;