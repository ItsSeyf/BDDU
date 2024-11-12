create database Universidad;

use Universidad;
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Create table Usuarios
(
	Nombre			varchar(20)	not null,
	Cargo			int	not null,
	Nombre_usuario	varchar(20)	not null,
	Contrasenia		nvarchar(128)	not null,
	Identificar		uniqueidentifier	not null
	Constraint PK_usuario Primary key(Nombre_usuario)
);

CREATE PROCEDURE sp_InsertarUsuario
    @Nombre VARCHAR(20),
    @Cargo INT,
    @NombreUsuario VARCHAR(20),
	@Contra	NVArCHAR(30)
	AS
	declare @Contrasenia NVARCHAR(30);
	declare @salt uniqueidentifier;
	declare @hasedpassword nvarchar(128);
	set @Contrasenia=@Contra;
	Set @salt = NEWID();
	set @hasedpassword=HASHBYTES('SHA2_256',@Contrasenia+CAST(@salt as nvarchar(36)));
    INSERT INTO Usuarios
    VALUES (@Nombre, @Cargo, @NombreUsuario, @hasedpassword, @salt);

create procedure sp_iniciarsesion
    @NombreUsuario VARCHAR(20),
	@Contra	NVArCHAR(30)
	as
	declare @Contrasenia NVARCHAR(30);
	declare @salt uniqueidentifier;
	declare @hasedpassword nvarchar(128);
	declare @encontrado int;
	set @Contrasenia=@Contra;
	Set @salt = (select Identificar from Usuarios where Nombre_usuario=@NombreUsuario);
	set @hasedpassword=HASHBYTES('SHA2_256',@Contrasenia+CAST(@salt as nvarchar(36)));
	set @encontrado=(select COUNT(*) from Usuarios where Nombre_usuario=@NombreUsuario and Contrasenia=@hasedpassword);
	if @encontrado>0
	begin
	select 'Usuario encontrado'
	end
	else
	begin
	select 'Usuario o contraseña, no existen o son incorrectos'
	end

CREATE PROCEDURE sp_EliminarUsuario
    @NombreUsuario VARCHAR(20)
AS
    DELETE FROM Usuarios
    WHERE Nombre_usuario = @NombreUsuario;

CREATE PROCEDURE sp_ActualizarUsuario
    @Nombre VARCHAR(20),
    @Cargo INT,
    @NombreUsuario VARCHAR(20),
    @Contrasenia VARCHAR(30)
AS
    UPDATE Usuarios
    SET Nombre = @Nombre, Cargo = @Cargo, Contrasenia = @Contrasenia
    WHERE Nombre_usuario = @NombreUsuario;
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Create table estudiantes
(
	cedula			int	not null,
	nombre			varchar(20)	not null,
	apellido1		varchar(20)	not null,
	apellido2		varchar(20) null,
	fecha_nac		date,
	carnet			varchar(20)	not null,
	tipo_estudiante	int		null
	Constraint PK_estudiantes Primary key(carnet)
);
Create unique index I_cedula on estudiantes(cedula);

CREATE PROCEDURE sp_InsertarEstudiante
    @Cedula INT,
    @Nombre VARCHAR(20),
    @Apellido1 VARCHAR(20),
    @Apellido2 VARCHAR(20) = NULL,
    @FechaNac DATE,
    @Carnet VARCHAR(20),
    @TipoEstudiante INT = NULL
AS
    INSERT INTO estudiantes (cedula, nombre, apellido1, apellido2, fecha_nac, carnet, tipo_estudiante)
    VALUES (@Cedula, @Nombre, @Apellido1, @Apellido2, @FechaNac, @Carnet, @TipoEstudiante);


CREATE PROCEDURE sp_EliminarEstudiante
    @Carnet VARCHAR(20)
AS
    DELETE FROM estudiantes
    WHERE carnet = @Carnet;

CREATE PROCEDURE sp_ActualizarEstudiante
    @Cedula INT,
    @Nombre VARCHAR(20),
    @Apellido1 VARCHAR(20),
    @Apellido2 VARCHAR(20) = NULL,
    @FechaNac DATE,
    @Carnet VARCHAR(20),
    @TipoEstudiante INT = NULL
AS
    UPDATE estudiantes
    SET cedula = @Cedula, nombre = @Nombre, apellido1 = @Apellido1, apellido2 = @Apellido2,
        fecha_nac = @FechaNac, tipo_estudiante = @TipoEstudiante
    WHERE carnet = @Carnet;
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table padecimientos
(
	carnet			varchar(20)	not	null,
	nombre			varchar(20)	not null,
	padecimiento	varchar(20)	not null
	Constraint PK_padecimiento Primary key(carnet)
	Constraint FK_padecimiento foreign key(carnet) references estudiantes(carnet)
);
CREATE PROCEDURE sp_InsertarPadecimiento
    @Carnet VARCHAR(20),
    @Nombre VARCHAR(20),
    @Padecimiento VARCHAR(20)
AS
    INSERT INTO Padecimientos (carnet, nombre, padecimiento)
    VALUES (@Carnet, @Nombre, @Padecimiento);

CREATE PROCEDURE sp_EliminarPadecimiento
    @Carnet VARCHAR(20),
    @Nombre VARCHAR(20)
AS
    DELETE FROM Padecimientos
    WHERE carnet = @Carnet AND nombre = @Nombre;

CREATE PROCEDURE sp_ActualizarPadecimiento
    @Carnet VARCHAR(20),
    @Nombre VARCHAR(20),
    @NuevoPadecimiento VARCHAR(20)
AS
    UPDATE Padecimientos
    SET padecimiento = @NuevoPadecimiento
    WHERE carnet = @Carnet AND nombre = @Nombre;
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table responsables
(
	cedula		int	not null,
	Nombre		varchar(20)	not null,
	apellido1	varchar(20)	not null,
	apellido2	varchar(20)	null,
	carnet		varchar(20)	not null
	Constraint PK_responsables Primary key(cedula)
	Constraint FK_responsables foreign key(carnet) references estudiantes(carnet)
);

CREATE PROCEDURE sp_InsertarResponsable
    @Cedula INT,
    @Nombre VARCHAR(20),
    @Apellido1 VARCHAR(20),
    @Apellido2 VARCHAR(20) = NULL,
    @Carnet VARCHAR(20)
AS

    INSERT INTO Responsables (cedula, Nombre, apellido1, apellido2, carnet)
    VALUES (@Cedula, @Nombre, @Apellido1, @Apellido2, @Carnet);

CREATE PROCEDURE sp_EliminarResponsable
    @Cedula INT
AS
    DELETE FROM Responsables
    WHERE cedula = @Cedula;

CREATE PROCEDURE sp_ActualizarResponsable
    @Cedula INT,
    @Nombre VARCHAR(20),
    @Apellido1 VARCHAR(20),
    @Apellido2 VARCHAR(20) = NULL,
    @Carnet VARCHAR(20)
AS
    UPDATE Responsables
    SET Nombre = @Nombre, apellido1 = @Apellido1, apellido2 = @Apellido2, carnet = @Carnet
    WHERE cedula = @Cedula;
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table profesiones
(
	id_profesion		int	not null,
	cedula_responsable	int	not null,
	lugar				varchar(60),
	profesion			varchar(30)
	Constraint PK_profesiones Primary key(id_profesion)
	Constraint FK_profesiones foreign key(cedula_responsable) references responsables(cedula)
);

CREATE PROCEDURE sp_InsertarProfesion
    @IdProfesion INT,
    @CedulaResponsable INT,
    @Lugar VARCHAR(60),
    @Profesion VARCHAR(30)
AS
    INSERT INTO Profesiones (id_profesion, cedula_responsable, lugar, profesion)
    VALUES (@IdProfesion, @CedulaResponsable, @Lugar, @Profesion);

CREATE PROCEDURE sp_EliminarProfesion
    @IdProfesion INT
AS
    DELETE FROM Profesiones
    WHERE id_profesion = @IdProfesion;

CREATE PROCEDURE sp_ActualizarProfesion
    @IdProfesion INT,
    @CedulaResponsable INT,
    @Lugar VARCHAR(60),
    @Profesion VARCHAR(30)
AS
    UPDATE Profesiones
    SET cedula_responsable = @CedulaResponsable, lugar = @Lugar, profesion = @Profesion
    WHERE id_profesion = @IdProfesion;
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table profesores
(
	cedula		int	not null,
	nombre		varchar(20)	not null,
	fec_ingreso	date	not null,
	horario		varchar(30)	not null
	Constraint PK_profesores Primary key(cedula)
);

CREATE PROCEDURE sp_InsertarProfesor
    @Cedula INT,
    @Nombre VARCHAR(20),
    @FechaIngreso DATE,
    @Horario VARCHAR(30)
AS
    INSERT INTO Profesores (cedula, nombre, fec_ingreso, horario)
    VALUES (@Cedula, @Nombre, @FechaIngreso, @Horario);

CREATE PROCEDURE sp_EliminarProfesor
    @Cedula INT
AS
    DELETE FROM Profesores
    WHERE cedula = @Cedula;

CREATE PROCEDURE sp_ActualizarProfesor
    @Cedula INT,
    @Nombre VARCHAR(20),
    @FechaIngreso DATE,
    @Horario VARCHAR(30)
AS
    UPDATE Profesores
    SET nombre = @Nombre, fec_ingreso = @FechaIngreso, horario = @Horario
    WHERE cedula = @Cedula;
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table cursos
(
	id_curso		varchar(30)	not null,
	cedula_profesor	int	not null,
	aula			varchar(10),
	descripcion		varchar(20),
	costo			money	not null
	Constraint PK_cursos Primary key(id_curso)
	Constraint FK_cursos foreign key(cedula_profesor) references profesores(cedula)
);
CREATE PROCEDURE sp_InsertarCurso
    @IdCurso VARCHAR(30),
    @CedulaProfesor INT,
    @Aula VARCHAR(10),
    @Descripcion VARCHAR(20),
    @Costo MONEY
AS
    INSERT INTO Cursos (id_curso, cedula_profesor, aula, descripcion, costo)
    VALUES (@IdCurso, @CedulaProfesor, @Aula, @Descripcion, @Costo);

CREATE PROCEDURE sp_EliminarCurso
    @IdCurso VARCHAR(30)
AS
    DELETE FROM Cursos
    WHERE id_curso = @IdCurso;

CREATE PROCEDURE sp_ActualizarCurso
    @IdCurso VARCHAR(30),
    @CedulaProfesor INT,
    @Aula VARCHAR(10),
    @Descripcion VARCHAR(20),
    @Costo MONEY
AS
    UPDATE Cursos
    SET cedula_profesor = @CedulaProfesor, aula = @Aula, descripcion = @Descripcion, costo = @Costo
    WHERE id_curso = @IdCurso;
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table cargos
(
	cargo		int	not null,
	desc_cargo	varchar(20)
	Constraint PK_cargos Primary key(cargo)
);

CREATE PROCEDURE sp_InsertarCargo
    @Cargo INT,
    @DescCargo VARCHAR(20)
AS
    INSERT INTO cargos (cargo, desc_cargo)
    VALUES (@Cargo, @DescCargo);

CREATE PROCEDURE sp_EliminarCargo
    @Cargo INT
	As
    DELETE FROM cargos
    WHERE cargo = @Cargo;

CREATE PROCEDURE sp_ActualizarCargo
    @Cargo INT,
    @DescCargo VARCHAR(20)
AS
    UPDATE cargos
    SET desc_cargo = @DescCargo
    WHERE cargo = @Cargo;

alter table usuarios add constraint FK_usuarios foreign key(Cargo) references cargos(cargo);
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table telefonos
(
	id_tel				int	not null,
	carnet				varchar(20)	null,
	cedula_responsable	int	null,
	nombre_usuario		varchar(20)	null,
	tipo_tel			int	not null,
	telefono			int	not null
	Constraint PK_telefonos Primary key (id_tel)
	Constraint FK_tel1 foreign key(carnet) references estudiantes(carnet)
);

CREATE PROCEDURE sp_InsertarTelefono
    @IdTel INT,
    @Carnet VARCHAR(20),
    @CedulaResponsable INT,
    @NombreUsuario VARCHAR(20),
    @TipoTel INT,
	@tel		int
AS
    INSERT INTO telefonos
    VALUES (@IdTel, @Carnet, @CedulaResponsable, @NombreUsuario, @TipoTel, @tel);

CREATE PROCEDURE sp_EliminarTelefono
    @IdTel INT
AS
    DELETE FROM telefonos
    WHERE id_tel = @IdTel;

CREATE PROCEDURE sp_ActualizarTelefono
    @IdTel INT,
    @Carnet VARCHAR(20) = NULL,
    @CedulaResponsable INT = NULL,
    @NombreUsuario VARCHAR(20) = NULL,
    @TipoTel INT,
	@tel		int
AS
    UPDATE telefonos
    SET carnet = @Carnet, cedula_responsable = @CedulaResponsable, nombre_usuario = @NombreUsuario, tipo_tel = @TipoTel, telefono=@tel
    WHERE id_tel = @IdTel;

alter table telefonos add Constraint FK_tel2 foreign key(cedula_responsable) references responsables(cedula);
alter table telefonos add Constraint FK_tel3 foreign key(nombre_usuario) references usuarios(Nombre_usuario);
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table tipo_tel
(
	tipo_tel	int	not null,
	desc_tel	varchar(20)
	Constraint PK_tipotel Primary key(tipo_tel)
);

CREATE PROCEDURE sp_InsertarTipoTelefono
    @TipoTel INT,
    @DescTel VARCHAR(20)
AS
    INSERT INTO tipo_tel (tipo_tel, desc_tel)
    VALUES (@TipoTel, @DescTel);

CREATE PROCEDURE sp_EliminarTipoTelefono
    @TipoTel INT
	as
    DELETE FROM tipo_tel
    WHERE tipo_tel = @TipoTel;


CREATE PROCEDURE sp_ActualizarTipoTelefono
    @TipoTel INT,
    @DescTel VARCHAR(20)
AS
    UPDATE tipo_tel
    SET desc_tel = @DescTel
    WHERE tipo_tel = @TipoTel;

alter table telefonos add constraint FK_tel4 foreign key(tipo_tel) references tipo_tel(tipo_tel);
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table direcciones
(
	id_direccion		int	not null,
	carnet				varchar(20) null,
	cedula_responsable	int null,
	direccion			varchar(60),
	tipo				int	not null
	Constraint PK_direcciones Primary key(id_direccion)
	Constraint FK_direcciones1 foreign key(carnet) references estudiantes(carnet)
);

CREATE PROCEDURE sp_InsertarDireccion
    @IdDireccion INT,
    @Carnet VARCHAR(20),
    @CedulaResponsable INT,
    @Direccion VARCHAR(60),
    @Tipo INT
AS
    INSERT INTO direcciones (id_direccion, carnet, cedula_responsable, direccion, tipo)
    VALUES (@IdDireccion, @Carnet, @CedulaResponsable, @Direccion, @Tipo);

CREATE PROCEDURE sp_EliminarDireccion
    @IdDireccion INT
AS
    DELETE FROM direcciones
    WHERE id_direccion = @IdDireccion;

CREATE PROCEDURE sp_ActualizarDireccion
    @IdDireccion INT,
    @Carnet VARCHAR(20) = NULL,
    @CedulaResponsable INT = NULL,
    @Direccion VARCHAR(60),
    @Tipo INT
AS
    UPDATE direcciones
    SET carnet = @Carnet, cedula_responsable = @CedulaResponsable, direccion = @Direccion, tipo = @Tipo
    WHERE id_direccion = @IdDireccion;

alter table direcciones add constraint FK_direcciones2 foreign key(cedula_responsable) references responsables(cedula);
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table tipo_direccion
(
	tipo_direccion	int	not null,
	desc_direccion	varchar(20)
	Constraint PK_tipodireccion Primary key(tipo_direccion)
);
CREATE PROCEDURE sp_InsertarTipoDireccion
    @TipoDireccion INT,
    @DescDireccion VARCHAR(20)
AS
    INSERT INTO tipo_direccion (tipo_direccion, desc_direccion)
    VALUES (@TipoDireccion, @DescDireccion);

CREATE PROCEDURE sp_EliminarTipoDireccion
    @TipoDireccion INT
AS
    DELETE FROM tipo_direccion
    WHERE tipo_direccion = @TipoDireccion;

CREATE PROCEDURE sp_ActualizarTipoDireccion
    @TipoDireccion INT,
    @DescDireccion VARCHAR(20)
AS
    UPDATE tipo_direccion
    SET desc_direccion = @DescDireccion
    WHERE tipo_direccion = @TipoDireccion;

alter table direcciones add constraint FK_direcciones3 foreign key(tipo) references tipo_direccion(tipo_direccion);
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table matriculas
(
	id_matricula	int				not null,
	carnet			varchar(20)		not null,
	total			money			not null,
	saldo			money			not null,
	fec_max_pago	date			not null,
	recargo			decimal(10,2)	not null
	Constraint PK_matricula	Primary key(id_matricula)
	Constraint FK_matricula1 foreign key(carnet) references estudiantes(carnet)
);

create proc sp_insertarmatricula
	@id			int,
	@carnet		varchar(20),
	@fec		date
	as
	declare 
	@total		money
	set @total=(select sum(c.costo) from cursos c, estudiante_curso e where e.curso=c.id_curso and e.carnet=@carnet);
	if @total>0
	begin
	insert into matriculas values (@id,@carnet,@total,@total,@fec,0);
	execute sp_actualizarcurso_estudianteid @id,@carnet
	end
	else
	begin
	select 'No se encontro ningun curso'
	end

	create procedure sp_actualizarcurso_estudianteid
	(
	@id	int,
	@carnet varchar(20)
	)
	as
	update estudiante_curso set id_matricula=@id where carnet=@carnet;

create procedure sp_actualizarmatricula
	@id			int,
	@carnet		varchar(20),
	@saldo		money,
	@total		money,
	@fec		date,
	@recargo	decimal(10,2)
	as
	declare @saldoo	money
	if @recargo>0.000
	begin
	set @saldoo=@recargo*@saldo+@saldo;
	update matriculas set carnet=@carnet, total=@total, saldo=@saldoo, fec_max_pago=@fec, recargo=@recargo where id_matricula=@id;
	end
	else
	begin
	update matriculas set carnet=@carnet, total=@total, saldo=@saldo, fec_max_pago=@fec, recargo=@recargo where id_matricula=@id;
	end

	create procedure sp_eliminarmatricula
	@id	int
	as
	delete from matricula where id_matricula=@id;
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table estudiante_curso
(
	carnet			varchar(20)	not null,
	curso			varchar(30)	not null,
	id_matricula	int		null,
	cuatri			varchar(20)	not null
	Constraint PK_estudiantecurso Primary key(carnet,curso,cuatri)
	Constraint FK_estudiantecurso1 foreign key(carnet) references estudiantes(carnet)
);
alter table estudiante_curso add constraint FK_estudiantecurso2 foreign key(curso) references cursos(id_curso);
alter table estudiante_curso add constraint FK_estudiantecurso3 foreign key(id_matricula) references matriculas(id_matricula);
create procedure sp_insertarestudiante_curso
	@carnet	varchar(20),
	@curso	varchar(30),
	@cuatri	varchar(20)
as
insert into estudiante_curso values(@carnet,@curso,null,@cuatri);

create procedure sp_actualizarestudiante_curso
	@carnet	varchar(20),
	@curso	varchar(30),
	@idm	int,
	@cuatri	varchar(20)
	as
	update estudiante_curso set carnet=@carnet, curso=@curso, id_matricula=@idm, cuatri=@cuatri;

create procedure sp_eliminarestudiante_curso
 @idm	int
 as delete from estudiante_curso where id_matricula=@idm;
 --////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table notas
(
	carnet		varchar(20)	not null,
	id_curso	varchar(30)	not null,
	profesor	int	not null,
	nota		decimal(12,2) not null
	Constraint PK_notas Primary key(carnet,id_curso,profesor)
	Constraint FK_notas1 foreign key(carnet) references estudiantes(carnet)
);

CREATE PROCEDURE sp_InsertarNota
    @Carnet VARCHAR(20),
    @IdCurso VARCHAR(30),
    @Profesor INT,
    @Nota DECIMAL(12,2)
AS
    INSERT INTO notas (carnet, id_curso, profesor, nota)
    VALUES (@Carnet, @IdCurso, @Profesor, @Nota);

CREATE PROCEDURE sp_EliminarNota
    @Carnet VARCHAR(20),
    @IdCurso VARCHAR(30),
    @Profesor INT
AS
    DELETE FROM notas
    WHERE carnet = @Carnet AND id_curso = @IdCurso AND profesor = @Profesor;

CREATE PROCEDURE sp_ActualizarNota
    @Carnet VARCHAR(20),
    @IdCurso VARCHAR(30),
    @Profesor INT,
    @Nota DECIMAL(12,2)
AS
    UPDATE notas
    SET nota = @Nota
    WHERE carnet = @Carnet AND id_curso = @IdCurso AND profesor = @Profesor;

alter table notas add constraint FK_notas2 foreign key(id_curso) references cursos(id_curso);
alter table notas add constraint FK_notas3 foreign key(profesor) references profesores(cedula);
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table tipo_estudiante
(
	tipo_estudiante	int	not null,
	desc_tipo		varchar(20)	not null
	Constraint PK_tipoestudiante Primary key(tipo_estudiante)
);

CREATE PROCEDURE sp_InsertarTipoEstudiante
    @TipoEstudiante INT,
    @DescTipo VARCHAR(20)
AS
    INSERT INTO tipo_estudiante (tipo_estudiante, desc_tipo)
    VALUES (@TipoEstudiante, @DescTipo);

CREATE PROCEDURE sp_EliminarTipoEstudiante
    @TipoEstudiante INT
AS
    DELETE FROM tipo_estudiante
    WHERE tipo_estudiante = @TipoEstudiante;

CREATE PROCEDURE sp_ActualizarTipoEstudiante
    @TipoEstudiante INT,
    @DescTipo VARCHAR(20)
AS
    UPDATE tipo_estudiante
    SET desc_tipo = @DescTipo
    WHERE tipo_estudiante = @TipoEstudiante;

alter table estudiantes add constraint FK_estudiantes foreign key(tipo_estudiante) references tipo_estudiante(tipo_estudiante);
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table requisitos
(
	carnet			varchar(20)	not null,
	tarjeta_medica	char(2)	default'NA',
	certificado_nac	char(2)	default'NA',
	foto_pasaporte	char(2) default'NA',
	expediente		char(2) default'NA',
	exp_adecua		char(2) default'NA',
	cert_traslado	char(2) default'NA'
	Constraint PK_requisitos	Primary key(carnet)
	Constraint FK_requisitos	foreign key(carnet) references estudiantes(carnet)
);

CREATE PROCEDURE sp_InsertarRequisitos
    @Carnet VARCHAR(20),
    @TarjetaMedica CHAR(2),
    @CertificadoNacimiento CHAR(2),
    @FotoPasaporte CHAR(2),
    @Expediente CHAR(2),
    @ExpedienteAdecua CHAR(2),
    @CertificadoTraslado CHAR(2)
AS
    INSERT INTO requisitos (carnet, tarjeta_medica, certificado_nac, foto_pasaporte, expediente, exp_adecua, cert_traslado)
    VALUES (@Carnet, @TarjetaMedica, @CertificadoNacimiento, @FotoPasaporte, @Expediente, @ExpedienteAdecua, @CertificadoTraslado);

CREATE PROCEDURE sp_ActualizarRequisitos
    @Carnet VARCHAR(20),
    @TarjetaMedica CHAR(2),
    @CertificadoNacimiento CHAR(2),
    @FotoPasaporte CHAR(2),
    @Expediente CHAR(2),
    @ExpedienteAdecua CHAR(2),
    @CertificadoTraslado CHAR(2)
AS
    UPDATE requisitos
    SET tarjeta_medica = @TarjetaMedica, certificado_nac = @CertificadoNacimiento, foto_pasaporte = @FotoPasaporte,
        expediente = @Expediente, exp_adecua = @ExpedienteAdecua, cert_traslado = @CertificadoTraslado
    WHERE carnet = @Carnet;

CREATE PROCEDURE sp_EliminarRequisitos
    @Carnet VARCHAR(20)
AS
    DELETE FROM requisitos
    WHERE carnet = @Carnet;
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table mensualidad
(
	id_matricula	int	not null,
	monto			money	not null,
	metodo_pago		int	not null,
	fecha_pago		date null,
	nombre_usuario	varchar(20)	not null
	Constraint PK_mensualidad Primary key(id_matricula)
	constraint FK_mensualidad1 foreign key(id_matricula) references matriculas(id_matricula)
);

create procedure sp_insertarmensualidad
	@id	int,
	@metodo_pago	int,
	@fecha	date,
	@monto	money,
	@nombre_usuario	varchar(20)
as
if @monto>0
begin
	insert into mensualidad values(@id, @monto, @metodo_pago, @fecha, @nombre_usuario)
end
else
begin
	declare
	@montoo	money
	set @montoo=(select total from matriculas where id_matricula=@id)/4
	insert into mensualidad values(@id, @montoo, @metodo_pago, @fecha, @nombre_usuario)
end
	execute sp_actualizarsaldo @monto, @fecha,@id;

	create procedure sp_actualizarsaldo
	@monto	money,
	@fec	date,
	@id		int
	as
	declare @saldo	money
	set @saldo=(select saldo from matriculas where id_matricula=@id);
	if @fec is not null
	begin
	update matriculas set saldo=(@saldo-@monto) where id_matricula=@id;
	end

	create procedure sp_actualizarmensualidad
	@id	int,
	@monto	money,
	@metodo	int,
	@fec	date,
	@usuario	varchar(20)
	as
	update mensualidad set monto=monto,metodo_pago=@metodo, fecha_pago=@fec, nombre_usuario=@usuario where id_matricula=@id;
	exec sp_actualizarsaldo @monto,@id, @fec;

	create procedure sp_eliminarmensualidad
	@id	int
	as
	delete mensualidad where id_matricula=@id;

alter table mensualidad add constraint FK_mensualidad2 foreign key(nombre_usuario) references Usuarios(Nombre_usuario);
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table metodo_pago
(
	metodo_pago	int	not null,
	desc_pago	varchar(20),
	moneda		int
	Constraint PK_metodopago Primary key(metodo_pago)
);

CREATE PROCEDURE sp_InsertarMetodoPago
    @MetodoPago INT,
    @DescPago VARCHAR(20),
    @Moneda INT
AS
    INSERT INTO metodo_pago (metodo_pago, desc_pago, moneda)
    VALUES (@MetodoPago, @DescPago, @Moneda);

CREATE PROCEDURE sp_EliminarMetodoPago
    @MetodoPago INT
AS
    DELETE FROM metodo_pago
    WHERE metodo_pago = @MetodoPago;

CREATE PROCEDURE sp_ActualizarMetodoPago
    @MetodoPago INT,
    @DescPago VARCHAR(20),
    @Moneda INT
AS
    UPDATE metodo_pago
    SET desc_pago = @DescPago, moneda = @Moneda
    WHERE metodo_pago = @MetodoPago;

alter table mensualidad add constraint FK_mensualidad3 foreign key(metodo_pago) references metodo_pago(metodo_pago);
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
create table monedas
(
	tipo_moneda	int	not null,
	desc_moneda	varchar(10)
	Constraint PK_monedas Primary key(tipo_moneda)
);
CREATE PROCEDURE sp_InsertarMoneda
    @TipoMoneda INT,
    @DescMoneda VARCHAR(10)
AS
    INSERT INTO monedas (tipo_moneda, desc_moneda)
    VALUES (@TipoMoneda, @DescMoneda);

CREATE PROCEDURE sp_EliminarMoneda
    @TipoMoneda INT
AS
    DELETE FROM monedas
    WHERE tipo_moneda = @TipoMoneda;

CREATE PROCEDURE sp_ActualizarMoneda
    @TipoMoneda INT,
    @DescMoneda VARCHAR(10)
AS
    UPDATE monedas
    SET desc_moneda = @DescMoneda
    WHERE tipo_moneda = @TipoMoneda;

alter table metodo_pago add constraint FK_metodopago foreign key(moneda) references monedas(tipo_moneda);
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
EXEC sp_InsertarUsuario 'Juan', 1, 'Juanito1', 'contrasena123';
create login Juan with
EXEC sp_InsertarUsuario 'María', 2, 'Maria1', 'clave456';
EXEC sp_InsertarUsuario 'Carlos', 3, 'Carlitos1', 'pwd789';
EXEC sp_InsertarUsuario 'Ana', 2, 'Anita1', 'password123';
EXEC sp_InsertarUsuario 'Pedro', 1, 'Pedrito1', 'abcd1234';

exec sp_InsertarTelefono 1,'JPG1',null,null,1,65656565;
exec sp_InsertarTelefono 2,null,1,null,2,77777777;
exec sp_InsertarTelefono 3,null,null,'Juanito1',3,88888888;
exec sp_InsertarTelefono 4,null,null,'Anita1',4,99999999;
exec sp_InsertarTelefono 5,'HPG1',null,null,5,222222222;

exec sp_InsertarRequisitos 'JPG1','Si','Si','Si','No','No','Si';
exec sp_InsertarRequisitos 'PPG1','Si','Si','Si','No','No','Si';
exec sp_InsertarRequisitos 'MPG1','No','Si','Si','No','No','Si';
exec sp_InsertarRequisitos 'HPG1','Si','Si','Si','Si','Si','Si';
exec sp_InsertarRequisitos 'RPG1','No','No','No','No','No','No';

exec sp_InsertarTipoEstudiante 1,'Interactivo';
exec sp_InsertarTipoEstudiante 2,'Transicion';
exec sp_InsertarTipoEstudiante 3,'Primaria';

execute sp_InsertarEstudiante 1,'Pepe','Perez','Gonzales','2000/04/20','PPG1',1;
execute sp_InsertarEstudiante 2,'Julian','Perez','Gonzales','2000/05/20','JPG1',2;
execute sp_InsertarEstudiante 3,'Mario','Perez','Gonzales','2000/06/20','MPG1',3;
execute sp_InsertarEstudiante 4,'Hector','Perez','Gonzales','2000/07/20','HPG1',1;
execute sp_InsertarEstudiante 5,'Ricardo','Perez','Gonzales','2000/08/20','RPG1',1;

execute sp_InsertarPadecimiento 'JPG1','Julian','Asma';
execute sp_InsertarPadecimiento 'PPG1','Perez','Asma';
execute sp_InsertarPadecimiento 'MPG1','Mario','Asma';
execute sp_InsertarPadecimiento 'RPG1','Mario','Alergias';
execute sp_InsertarPadecimiento 'HPG1','Hector','Asma';

execute sp_InsertarResponsable 1,'Maria','Perez','Guzman','JPG1';
execute sp_InsertarResponsable 2,'Diego','Perez','Guzman','PPG1';
execute sp_InsertarResponsable 3,'Hugo','Perez','Guzman','MPG1';
execute sp_InsertarResponsable 4,'Abigail','Perez','Guzman','HPG1';
execute sp_InsertarResponsable 5,'Cristian','Guzman','Gonzales','RPG1';

execute sp_InsertarProfesion 1,1,'Cartago','Doctora';
execute sp_InsertarProfesion 2,2,'San Jose','Policia';
execute sp_InsertarProfesion 3,3,'Heredia','Bombero';
execute sp_InsertarProfesion 4,4,'Cartago','Periodista';
execute sp_InsertarProfesion 5,5,'Cartago','Paramedico';

execute sp_InsertarCurso 1,1,'A4','Ingles',50000;
execute sp_InsertarCurso 2,2,'A6','Ciencias',60000;
execute sp_InsertarCurso 3,3,'B4','Matematica',70000;
execute sp_InsertarCurso 4,4,'A7','Artes Plasticas',80000;
execute sp_InsertarCurso 5,5,'C4','Religion',40000;

execute sp_InsertarCargo 1,'Profesor';
execute sp_InsertarCargo 2,'Conserje';
execute sp_InsertarCargo 3,'Director';
execute sp_InsertarCargo 4,'Seguridad';
execute sp_InsertarCargo 5,'Supervisor';

execute sp_InsertarMoneda 1,'Colones';
execute sp_InsertarMoneda 2,'Dolares';

execute sp_InsertarMetodoPago 1,'Tarjeta',1;
execute sp_InsertarMetodoPago 2,'Efectivo',2;
execute sp_InsertarMetodoPago 3,'Tarjeta',2;
execute sp_InsertarMetodoPago 4,'Efectivo',1;

execute sp_InsertarTipoDireccion 1,'Personal';
execute sp_InsertarTipoDireccion 2,'Trabajo';
execute sp_InsertarTipoDireccion 3,'Casa 2';
execute sp_InsertarTipoDireccion 4,'Trabajo2';
execute sp_InsertarTipoDireccion 5,'Padres';

exec sp_InsertarDireccion 1,'JPG1',null,'Cartago',1;
exec sp_InsertarDireccion 2,null,1,'Cartago',2;
exec sp_InsertarDireccion 3,null,2,'Cartago',3;
exec sp_InsertarDireccion 4,'RPG1',null,'Cartago',4;
exec sp_InsertarDireccion 5,'HPG1',null,'Cartago',5;

execute sp_InsertarTipoTelefono 1,'Personal';
execute sp_InsertarTipoTelefono 2,'Trabajo';
execute sp_InsertarTipoTelefono 3,'Casa 2';
execute sp_InsertarTipoTelefono 4,'Trabajo2';
execute sp_InsertarTipoTelefono 5,'Padres';

exec sp_insertarestudiante_curso 'PPG1',1,'2C';
exec sp_insertarestudiante_curso 'PPG1',2,'3C';
exec sp_insertarestudiante_curso 'HPG1',3,'1C';
exec sp_insertarestudiante_curso 'RPG1',4,'2C';
exec sp_insertarestudiante_curso 'RPG1',5,'3C';
exec sp_insertarestudiante_curso 'MPG1',5,'3C';
exec sp_insertarestudiante_curso 'JPG1',5,'3C';

execute sp_InsertarProfesor 1,'Hugo','2022/02/01','7am-3pm';
execute sp_InsertarProfesor 2,'Julio','2022/02/01','7am-3pm';
execute sp_InsertarProfesor 3,'Ricardo','2022/02/01','9am-5pm';
execute sp_InsertarProfesor 4,'Cristian','2022/02/01','7am-3pm';
execute sp_InsertarProfesor 5,'Mike','2022/02/01','8am-4pm';

exec sp_InsertarNota 'PPG1',1,1,80.00;
exec sp_InsertarNota 'HPG1',3,3,70.00;
exec sp_InsertarNota 'PPG1',2,2,90.00;
exec sp_InsertarNota 'RPG1',4,4,60.00;
exec sp_InsertarNota 'JPG1',5,5,69.00;

exec sp_actualizarmatricula 4,'MPG1',30000,40000,'2023/10/21',0.05;

exec sp_actualizarmatricula 2,'HPG1',0,70000,'2024/08/21',0;

exec sp_insertarmatricula 1,'PPG1','2024/07/21';
exec sp_insertarmatricula 2,'HPG1','2024/08/21';
exec sp_insertarmatricula 3,'RPG1','2024/09/21';
exec sp_insertarmatricula 4,'MPG1','2023/10/21';
exec sp_insertarmatricula 5,'JPG1','2022/11/21';

select * from matriculas;
exec sp_insertarmensualidad 1,1,'2024/05/23',110000,'Juanito1';
exec sp_insertarmensualidad 2,2,'2024/09/21',70000,'Maria1';
exec sp_insertarmensualidad 3,3,'2024/10/21',120000,'Carlitos1';
exec sp_insertarmensualidad 4,4,'2024/02/21',30000,'Anita1';
exec sp_insertarmensualidad 5,2,'2022/12/21',40000,'Pedrito1';
select * from mensualidad;

delete from mensualidad where id_matricula=4;

exec sp_iniciarsesion 'Juanito1','contrasena123';

create login Hugo with password = 'H8g0', default_database=Universidad, default_language=spanish;
create user Hugo for login Hugo with default_schema=Universidad;

create login Ronaldo with password='R0n4ld0', default_database=Universidad, default_language=spanish;
create user Ronaldo for login Ronaldo with default_schema=Universidad;
exec sp_addrolemember 'Director','Ronaldo';

create role Director authorization dbo;

create role Profesores;
grant select,update,delete on cursos to Profesores;
grant select,update,delete on notas to Profesores;
alter role Profesores add member Hugo;

create role Asistentes;
grant select,update,delete,insert on matriculas to Asistentes;
grant select,update,delete,insert on cursos to Asistentes;
grant select,update,delete,insert on estudiante_curso to Asistentes;
grant select,update,delete,insert on padecimientos to Asistentes;
grant select,update,delete,insert on responsables to Asistentes;
grant select,update,delete,insert on mensualidad to Asistentes;
grant select,update,delete,insert on direcciones to Asistentes;


create login Juan with password = 'contrasena123', default_database=Universidad, default_language=spanish;
create user Juan for login Juan with default_schema=Universidad;
alter role Asistentes add member Juan;
create login Maria with password = 'clave456', default_database=Universidad, default_language=spanish;
create user Maria for login Maria with default_schema=Universidad;
alter role Asistentes add member Maria;
create login Carlos with password = 'pwd789', default_database=Universidad, default_language=spanish;
create user Carlos for login Carlos with default_schema=Universidad;
alter role Asistentes add member Carlos;
create login Ana with password = 'password123', default_database=Universidad, default_language=spanish;
create user Ana for login Ana with default_schema=Universidad;
alter role Asistentes add member Ana;

create view v_requisitos
as
select r.carnet,r.tarjeta_medica,r.certificado_nac,r.foto_pasaporte,r.expediente,r.exp_adecua,r.cert_traslado, t.desc_tipo as 'Tipo Estudiante' from requisitos r, estudiantes e, tipo_estudiante t where r.carnet=e.carnet and e.tipo_estudiante= t.tipo_estudiante;

select * from v_requisitos;

create procedure sp_reporte
	as
	select e.nombre,r.Nombre,t.telefono, m.fecha_pago,m.monto, 0 as 'Dias atraso', 'Al dia' as 'Atraso' from estudiantes e, responsables r, telefonos t, mensualidad m, matriculas mm where e.carnet=r.carnet and e.carnet=t.carnet and e.carnet=mm.carnet and m.id_matricula=mm.id_matricula and mm.saldo=0;
	select e.nombre,r.Nombre,t.telefono, m.fecha_pago,m.monto, DATEDIFF(Day,mm.fec_max_pago,GETDATE()) as 'Dias atraso', 'Moroso' as 'Atraso' from estudiantes e, responsables r, telefonos t, mensualidad m, matriculas mm where e.carnet=r.carnet and e.carnet=t.carnet and e.carnet=mm.carnet and m.id_matricula=mm.id_matricula and mm.saldo>0 and DATEDIFF(Day,mm.fec_max_pago,GETDATE())>0;


create procedure sp_verificar
	@id	varchar(20)
	as
	select e.cedula,e.nombre,e.apellido1,e.apellido2, r.Nombre as 'Responsable', e.fecha_nac, p.padecimiento, d.direccion from estudiantes e, direcciones d, telefonos t, padecimientos p, responsables r where e.carnet=@id and e.carnet=d.carnet and e.carnet=t.carnet and e.carnet=p.carnet and e.carnet=r.carnet;

	exec sp_verificar 'JPG1';

create procedure sp_notas
as
	select id_curso as Curso, profesor as Profesor, nota as Nota, 'Aprobado' as 'Estado' from notas where nota>70
	Union
	select id_curso as Curso, profesor as Profesor, nota as Nota, 'Reprobado' as 'Estado' from notas where nota<70

	exec sp_notas;

		select e.nombre,r.Nombre,t.telefono, m.fecha_pago,m.monto, DATEDIFF(Day,mm.fec_max_pago,GETDATE()) as 'Dias atraso', 'Moroso' as 'Atraso' from estudiantes e, responsables r, telefonos t, mensualidad m, matriculas mm where e.carnet=r.carnet and e.carnet=t.carnet and e.carnet=mm.carnet and m.id_matricula=mm.id_matricula and mm.saldo>0;