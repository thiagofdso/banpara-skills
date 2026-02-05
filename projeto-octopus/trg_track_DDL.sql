USE [master]
GO

/****** Object:  DdlTrigger [trg_track_DDL]    Script Date: 18/08/2025 16:55:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER TRIGGER [trg_track_DDL]
ON ALL SERVER
FOR DDL_EVENTS
AS
BEGIN
    DECLARE @data XML,
            @eventType VARCHAR(100),
            @eventTime DATETIME,
            @serverName VARCHAR(100),
            @databaseName VARCHAR(100),
            @schemaName VARCHAR(100),
            @objectName VARCHAR(100),
            @objectType VARCHAR(100),
            @whoDidIt VARCHAR(100),
            @tsql VARCHAR(4000),
            @spid INT,
            @whereItFrom VARCHAR(100),
            @loginOriginal VARCHAR(100),
            @loginAtual VARCHAR(100),
            @temPermissaoInsert BIT;

    SET @data = EVENTDATA();
    SET @eventType   = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(100)');
    SET @eventTime   = @data.value('(/EVENT_INSTANCE/PostTime)[1]', 'datetime');
    SET @serverName  = @data.value('(/EVENT_INSTANCE/ServerName)[1]', 'varchar(100)');
    SET @databaseName= @data.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'varchar(100)');
    SET @schemaName  = @data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'varchar(100)');
    SET @objectName  = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(100)');
    SET @objectType  = @data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(100)');
    SET @whoDidIt    = @data.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(100)');
    SET @tsql        = @data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'varchar(4000)');
    SET @spid        = @data.value('(/EVENT_INSTANCE/SPID)[1]', 'int');

    SELECT @whereItFrom = hostname 
    FROM sys.sysprocesses
    WHERE spid = @spid;

    SET @loginOriginal      = ORIGINAL_LOGIN();
    SET @loginAtual         = SUSER_SNAME();
    SET @temPermissaoInsert = HAS_PERMS_BY_NAME('Octopus.dbo.TRACK_DDL', 'OBJECT', 'INSERT');

    IF NOT (@eventType IN (
        'CREATE_LOGIN', 'DROP_LOGIN', 'ALTER_LOGIN', 'CREATE_USER', 'ALTER_USER',
        'DROP_USER', 'GRANT_DATABASE', 'REVOKE_DATABASE', 
        'UPDATE_STATISTICS', 'ADD_SERVER_ROLE_MEMBER', 'DROP_SERVER_ROLE_MEMBER',
        'ADD_ROLE_MEMBER', 'DROP_ROLE_MEMBER', 'ALTER_INSTANCE', 'CREATE_SERVER_AUDIT',
        'ALTER_SERVER_AUDIT', 'DROP_SERVER_AUDIT', 'ALTER_DATABASE_SCOPED_CONFIGURATION',
        'ALTER_AUTHORIZATION_DATABASE', 'CREATE_DATABASE_AUDIT_SPECIFICATION',
        'ALTER_DATABASE_AUDIT_SPECIFICATION', 'DROP_DATABASE_AUDIT_SPECIFICATION',
        'GRANT_SERVER', 'REVOKE_SERVER', 'CREATE_SCHEMA' , 'DROP_SCHEMA', 'CREATE_MESSAGE',
        'DENY_SERVER','ALTER_CREDENTIAL','ALTER_DATABASE','CREATE_ASSEMBLY','ALTER_ASSEMBLY',
        'DROP_ASSEMBLY','CREATE_QUEUE','ALTER_QUEUE','DROP_QUEUE','CREATE_SERVICE','ALTER_SERVICE',
        'DROP_SERVICE','CREATE_RULE','DROP_RULE','CREATE_DEFAULT','DROP_DEFAULT','CREATE_TYPE',
        'DROP_TYPE','CREATE_SEQUENCE','ALTER_SEQUENCE','DROP_SEQUENCE','CREATE_SYNONYM','DROP_SYNONYM',
        'CREATE_STATISTICS','DROP_STATISTICS'
    ))
    BEGIN
        -- Filtrar comandos de REBUILD PARTITION ou REORGANIZE
        IF @tsql NOT LIKE '%REBUILD PARTITION%' AND @tsql NOT LIKE '%REORGANIZE%'
        BEGIN
            IF @temPermissaoInsert = 1
            BEGIN
                INSERT INTO Octopus.dbo.TRACK_DDL
                (
                    eventType,
                    eventTime,
                    serverName,
                    databaseName,
                    schemaName,
                    objectName,
                    objectType,
                    whoDidIt,
                    tsql_text,
                    whereItFrom
                )
                VALUES
                (
                    @eventType,
                    @eventTime,
                    @serverName,
                    @databaseName,
                    @schemaName,
                    @objectName,
                    @objectType,
                    @whoDidIt,
                    @tsql,
                    @whereItFrom
                );
            END
            ELSE
            BEGIN
                PRINT 'TRACK_DDL bloqueado - Sem permissão INSERT para [' + @loginAtual + 
                      '] (Original: [' + @loginOriginal + ']) no evento: ' + @eventType;
            END
        END
    END
END
GO
