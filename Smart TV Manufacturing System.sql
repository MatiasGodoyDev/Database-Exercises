-- Create the database
CREATE DATABASE FabricaSmartTV;
USE FabricaSmartTV;

-- Employee table
CREATE TABLE Empleado (
    ID_Empleado INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    salario decimal(10,2),
    Fecha_Contratacion DATE NOT NULL
);

-- Component table
CREATE TABLE Componente (
    ID_Componente INT AUTO_INCREMENT PRIMARY KEY,
    Nombre_Componente VARCHAR(100) NOT NULL,
    Tipo_Componente ENUM('Fabricado', 'Comprado') NOT NULL,
    Precio DECIMAL(10,2) NOT NULL
);

-- TV Model table
CREATE TABLE TV_Modelo (
    ID_TV_Modelo INT AUTO_INCREMENT PRIMARY KEY,
    Nombre_Modelo VARCHAR(100) NOT NULL,
    Descripcion TEXT
);

-- Importer table
CREATE TABLE Importador (
    ID_Importador INT AUTO_INCREMENT PRIMARY KEY,
    Nombre_Importador VARCHAR(100) NOT NULL,
    Pais VARCHAR(50) NOT NULL
);

-- Purchase Order table
CREATE TABLE Orden_Compra (
    ID_Orden INT AUTO_INCREMENT PRIMARY KEY,
    Fecha_Compra DATE NOT NULL,
    ID_Componente INT NOT NULL,
    ID_Importador INT NOT NULL,
    Cantidad INT NOT NULL,
    FOREIGN KEY (ID_Componente) REFERENCES Componente(ID_Componente),
    FOREIGN KEY (ID_Importador) REFERENCES Importador(ID_Importador)
);

-- Work Sheet table
CREATE TABLE Hoja_Trabajo (
    ID_Hoja_Trabajo INT AUTO_INCREMENT PRIMARY KEY,
    Fecha DATE NOT NULL,
    Cantidad_Fabricada INT NOT NULL,
    ID_Componente INT NOT NULL,
    ID_Empleado INT NOT NULL,
    FOREIGN KEY (ID_Componente) REFERENCES Componente(ID_Componente),
    FOREIGN KEY (ID_Empleado) REFERENCES Empleado(ID_Empleado)
);

-- Assembly Map table
CREATE TABLE Mapa_Armado (
    ID_Mapa INT AUTO_INCREMENT PRIMARY KEY,
    ID_TV_Modelo INT NOT NULL,
    ID_Componente INT NOT NULL,
    Ubicacion VARCHAR(100) NOT NULL,
    Orden INT NOT NULL,
    FOREIGN KEY (ID_TV_Modelo) REFERENCES TV_Modelo(ID_TV_Modelo),
    FOREIGN KEY (ID_Componente) REFERENCES Componente(ID_Componente)
);

-- Query 1: Get employee name, component name, manufactured quantity, and work date
SELECT 
    e.Nombre, 
    e.Apellido, 
    c.Nombre_Componente, 
    ht.Cantidad_Fabricada, 
    ht.Fecha
FROM 
    Empleado e
JOIN 
    Hoja_Trabajo ht ON e.ID_Empleado = ht.ID_Empleado
JOIN 
    Componente c ON ht.ID_Componente = c.ID_Componente;
    
-- Query 2: Get TV model name and associated component names
SELECT 
    m.Nombre_Modelo, 
    c.Nombre_Componente
FROM 
    TV_Modelo m
JOIN 
    Mapa_Armado ma ON m.ID_TV_Modelo = ma.ID_TV_Modelo
JOIN 
    Componente c ON ma.ID_Componente = c.ID_Componente;
