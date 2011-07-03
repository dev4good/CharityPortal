/*
Deployment script for charityportal
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "charityportal"
:setvar DefaultDataPath "D:\sql2008\MSSQL10_50.SQL2008\MSSQL\DATA\"
:setvar DefaultLogPath "D:\sql2008\MSSQL10_50.SQL2008\MSSQL\Logs\"

GO
USE [master]

GO
:on error exit
GO
IF (DB_ID(N'$(DatabaseName)') IS NOT NULL
    AND DATABASEPROPERTYEX(N'$(DatabaseName)','Status') <> N'ONLINE')
BEGIN
    RAISERROR(N'The state of the target database, %s, is not set to ONLINE. To deploy to this database, its state must be set to ONLINE.', 16, 127,N'$(DatabaseName)') WITH NOWAIT
    RETURN
END

GO
IF (DB_ID(N'$(DatabaseName)') IS NOT NULL) 
BEGIN
    ALTER DATABASE [$(DatabaseName)]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [$(DatabaseName)];
END

GO
PRINT N'Creating $(DatabaseName)...'
GO
CREATE DATABASE [$(DatabaseName)]
    ON 
    PRIMARY(NAME = [charityportal], FILENAME = N'$(DefaultDataPath)charityportal.mdf')
    LOG ON (NAME = [charityportal_log], FILENAME = N'$(DefaultLogPath)charityportal_log.ldf') COLLATE SQL_Latin1_General_CP1_CI_AS
GO
EXECUTE sp_dbcmptlevel [$(DatabaseName)], 100;


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS ON,
                ANSI_PADDING ON,
                ANSI_WARNINGS ON,
                ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                NUMERIC_ROUNDABORT OFF,
                QUOTED_IDENTIFIER ON,
                ANSI_NULL_DEFAULT ON,
                CURSOR_DEFAULT LOCAL,
                RECOVERY FULL,
                CURSOR_CLOSE_ON_COMMIT OFF,
                AUTO_CREATE_STATISTICS ON,
                AUTO_SHRINK OFF,
                AUTO_UPDATE_STATISTICS ON,
                RECURSIVE_TRIGGERS OFF 
            WITH ROLLBACK IMMEDIATE;
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_CLOSE OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ALLOW_SNAPSHOT_ISOLATION OFF;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET READ_COMMITTED_SNAPSHOT OFF;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_UPDATE_STATISTICS_ASYNC OFF,
                PAGE_VERIFY NONE,
                DATE_CORRELATION_OPTIMIZATION OFF,
                DISABLE_BROKER,
                PARAMETERIZATION SIMPLE,
                SUPPLEMENTAL_LOGGING OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF IS_SRVROLEMEMBER(N'sysadmin') = 1
    BEGIN
        IF EXISTS (SELECT 1
                   FROM   [master].[dbo].[sysdatabases]
                   WHERE  [name] = N'$(DatabaseName)')
            BEGIN
                EXECUTE sp_executesql N'ALTER DATABASE [$(DatabaseName)]
    SET TRUSTWORTHY OFF,
        DB_CHAINING OFF 
    WITH ROLLBACK IMMEDIATE';
            END
    END
ELSE
    BEGIN
        PRINT N'The database settings cannot be modified. You must be a SysAdmin to apply these settings.';
    END


GO
IF IS_SRVROLEMEMBER(N'sysadmin') = 1
    BEGIN
        IF EXISTS (SELECT 1
                   FROM   [master].[dbo].[sysdatabases]
                   WHERE  [name] = N'$(DatabaseName)')
            BEGIN
                EXECUTE sp_executesql N'ALTER DATABASE [$(DatabaseName)]
    SET HONOR_BROKER_PRIORITY OFF 
    WITH ROLLBACK IMMEDIATE';
            END
    END
ELSE
    BEGIN
        PRINT N'The database settings cannot be modified. You must be a SysAdmin to apply these settings.';
    END


GO
USE [$(DatabaseName)]

GO
IF fulltextserviceproperty(N'IsFulltextInstalled') = 1
    EXECUTE sp_fulltext_database 'enable';


GO
/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

GO
PRINT N'Creating [dbo].[Organizations]...';


GO
CREATE TABLE [dbo].[Organizations] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (MAX) NOT NULL,
    [ContactEmail] NVARCHAR (MAX) NOT NULL
);


GO
PRINT N'Creating PK_Organizations...';


GO
ALTER TABLE [dbo].[Organizations]
    ADD CONSTRAINT [PK_Organizations] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);


GO
PRINT N'Creating [dbo].[Projects]...';


GO
CREATE TABLE [dbo].[Projects] (
    [Id]                   INT            IDENTITY (1, 1) NOT NULL,
    [Name]                 NVARCHAR (MAX) NOT NULL,
    [Description]          NVARCHAR (MAX) NOT NULL,
    [IsActive]             BIT            NOT NULL,
    [Location_Longitude]   FLOAT          NOT NULL,
    [Location_Latitude]    FLOAT          NOT NULL,
    [Location_Address]     NVARCHAR (MAX) NOT NULL,
    [AdminOrganization_Id] INT            NOT NULL
);


GO
PRINT N'Creating PK_Projects...';


GO
ALTER TABLE [dbo].[Projects]
    ADD CONSTRAINT [PK_Projects] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);


GO
PRINT N'Creating [dbo].[Projects].[IX_FK_OrganizationProject]...';


GO
CREATE NONCLUSTERED INDEX [IX_FK_OrganizationProject]
    ON [dbo].[Projects]([AdminOrganization_Id] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF, ONLINE = OFF, MAXDOP = 0);


GO
PRINT N'Creating [dbo].[Resources]...';


GO
CREATE TABLE [dbo].[Resources] (
    [Id]                            BIGINT         IDENTITY (1, 1) NOT NULL,
    [Title]                         NVARCHAR (MAX) NOT NULL,
    [Description]                   NVARCHAR (MAX) NOT NULL,
    [Quantity]                      FLOAT          NOT NULL,
    [QuantityUnits]                 NVARCHAR (MAX) NOT NULL,
    [Location_Longitude]            FLOAT          NOT NULL,
    [Location_Latitude]             FLOAT          NOT NULL,
    [Location_Address]              NVARCHAR (MAX) NOT NULL,
    [Project_Id]                    INT            NOT NULL,
    [Organization_Id]               INT            NOT NULL,
    [ResourceResource_Resource1_Id] BIGINT         NOT NULL
);


GO
PRINT N'Creating PK_Resources...';


GO
ALTER TABLE [dbo].[Resources]
    ADD CONSTRAINT [PK_Resources] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);


GO
PRINT N'Creating [dbo].[Resources].[IX_FK_OrganizationResource]...';


GO
CREATE NONCLUSTERED INDEX [IX_FK_OrganizationResource]
    ON [dbo].[Resources]([Organization_Id] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF, ONLINE = OFF, MAXDOP = 0);


GO
PRINT N'Creating [dbo].[Resources].[IX_FK_ProjectResource]...';


GO
CREATE NONCLUSTERED INDEX [IX_FK_ProjectResource]
    ON [dbo].[Resources]([Project_Id] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF, ONLINE = OFF, MAXDOP = 0);


GO
PRINT N'Creating [dbo].[Resources].[IX_FK_ResourceResource]...';


GO
CREATE NONCLUSTERED INDEX [IX_FK_ResourceResource]
    ON [dbo].[Resources]([ResourceResource_Resource1_Id] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF, ONLINE = OFF, MAXDOP = 0);


GO
PRINT N'Creating [dbo].[TagResource]...';


GO
CREATE TABLE [dbo].[TagResource] (
    [Tag_Id]       INT    NOT NULL,
    [Resources_Id] BIGINT NOT NULL
);


GO
PRINT N'Creating PK_TagResource...';


GO
ALTER TABLE [dbo].[TagResource]
    ADD CONSTRAINT [PK_TagResource] PRIMARY KEY NONCLUSTERED ([Tag_Id] ASC, [Resources_Id] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);


GO
PRINT N'Creating [dbo].[TagResource].[IX_FK_TagResource_Resource]...';


GO
CREATE NONCLUSTERED INDEX [IX_FK_TagResource_Resource]
    ON [dbo].[TagResource]([Resources_Id] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF, ONLINE = OFF, MAXDOP = 0);


GO
PRINT N'Creating [dbo].[Tags]...';


GO
CREATE TABLE [dbo].[Tags] (
    [Id]   INT            IDENTITY (1, 1) NOT NULL,
    [Name] NVARCHAR (MAX) NOT NULL
);


GO
PRINT N'Creating PK_Tags...';


GO
ALTER TABLE [dbo].[Tags]
    ADD CONSTRAINT [PK_Tags] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);


GO
PRINT N'Creating FK_OrganizationProject...';


GO
ALTER TABLE [dbo].[Projects] WITH NOCHECK
    ADD CONSTRAINT [FK_OrganizationProject] FOREIGN KEY ([AdminOrganization_Id]) REFERENCES [dbo].[Organizations] ([Id]) ON DELETE NO ACTION ON UPDATE NO ACTION;


GO
PRINT N'Creating FK_OrganizationResource...';


GO
ALTER TABLE [dbo].[Resources] WITH NOCHECK
    ADD CONSTRAINT [FK_OrganizationResource] FOREIGN KEY ([Organization_Id]) REFERENCES [dbo].[Organizations] ([Id]) ON DELETE NO ACTION ON UPDATE NO ACTION;


GO
PRINT N'Creating FK_ProjectResource...';


GO
ALTER TABLE [dbo].[Resources] WITH NOCHECK
    ADD CONSTRAINT [FK_ProjectResource] FOREIGN KEY ([Project_Id]) REFERENCES [dbo].[Projects] ([Id]) ON DELETE NO ACTION ON UPDATE NO ACTION;


GO
PRINT N'Creating FK_ResourceResource...';


GO
ALTER TABLE [dbo].[Resources] WITH NOCHECK
    ADD CONSTRAINT [FK_ResourceResource] FOREIGN KEY ([ResourceResource_Resource1_Id]) REFERENCES [dbo].[Resources] ([Id]) ON DELETE NO ACTION ON UPDATE NO ACTION;


GO
PRINT N'Creating FK_TagResource_Resource...';


GO
ALTER TABLE [dbo].[TagResource] WITH NOCHECK
    ADD CONSTRAINT [FK_TagResource_Resource] FOREIGN KEY ([Resources_Id]) REFERENCES [dbo].[Resources] ([Id]) ON DELETE NO ACTION ON UPDATE NO ACTION;


GO
PRINT N'Creating FK_TagResource_Tag...';


GO
ALTER TABLE [dbo].[TagResource] WITH NOCHECK
    ADD CONSTRAINT [FK_TagResource_Tag] FOREIGN KEY ([Tag_Id]) REFERENCES [dbo].[Tags] ([Id]) ON DELETE NO ACTION ON UPDATE NO ACTION;


GO
-- Refactoring step to update target server with deployed transaction logs
CREATE TABLE  [dbo].[__RefactorLog] (OperationKey UNIQUEIDENTIFIER NOT NULL PRIMARY KEY)
GO
sp_addextendedproperty N'microsoft_database_tools_support', N'refactoring log', N'schema', N'dbo', N'table', N'__RefactorLog'
GO

GO
/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

GO
PRINT N'Checking existing data against newly created constraints';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[Projects] WITH CHECK CHECK CONSTRAINT [FK_OrganizationProject];

ALTER TABLE [dbo].[Resources] WITH CHECK CHECK CONSTRAINT [FK_OrganizationResource];

ALTER TABLE [dbo].[Resources] WITH CHECK CHECK CONSTRAINT [FK_ProjectResource];

ALTER TABLE [dbo].[Resources] WITH CHECK CHECK CONSTRAINT [FK_ResourceResource];

ALTER TABLE [dbo].[TagResource] WITH CHECK CHECK CONSTRAINT [FK_TagResource_Resource];

ALTER TABLE [dbo].[TagResource] WITH CHECK CHECK CONSTRAINT [FK_TagResource_Tag];


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        DECLARE @VarDecimalSupported AS BIT;
        SELECT @VarDecimalSupported = 0;
        IF ((ServerProperty(N'EngineEdition') = 3)
            AND (((@@microsoftversion / power(2, 24) = 9)
                  AND (@@microsoftversion & 0xffff >= 3024))
                 OR ((@@microsoftversion / power(2, 24) = 10)
                     AND (@@microsoftversion & 0xffff >= 1600))))
            SELECT @VarDecimalSupported = 1;
        IF (@VarDecimalSupported > 0)
            BEGIN
                EXECUTE sp_db_vardecimal_storage_format N'$(DatabaseName)', 'ON';
            END
    END


GO
