CREATE TABLE IF NOT EXISTS securityEventNames (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  UNIQUE INDEX securityEventNamesUnique(name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS securityEvents (
  uid BINARY(16) NOT NULL,
  nameId INT NOT NULL,
  FOREIGN KEY (nameId) REFERENCES securityEventNames(id) ON DELETE CASCADE,
  ipAddr BINARY(32) NOT NULL,
  createdAt BIGINT SIGNED NOT NULL
) ENGINE=InnoDB;

INSERT INTO
    securityEventNames (name)
VALUES
    ("account.create"),
    ("account.login"),
    ("account.confirm"),
    ("account.reset");

CREATE PROCEDURE `createSecurityEvent_1` (
    IN inUid BINARY(16),
    IN inName INT,
    IN inIpAddr BINARY(32),
    IN inCreatedAt BIGINT SIGNED
)
BEGIN
    INSERT INTO securityEvents(
        uid,
        nameId,
        ipAddr,
        createdAt
    )
    VALUES(
        inUid,
        inName,
        inIpAddr,
        inCreatedAt
    );
END;

CREATE PROCEDURE `fetchSecurityEvents_1` (
    IN inUid BINARY(16),
    IN inIpAddr BINARY(32),
    IN inNames TEXT
)
BEGIN
    CREATE TEMPORARY TABLE fetchSecurityNames AS (
        SELECT n.id, n.name FROM securityEventNames n
        WHERE FIND_IN_SET(n.name, inNames) > 0
    );

    SELECT
        n.name,
        e.createdAt
    FROM
        securityEvents e,
        fetchSecurityNames n
    WHERE
        e.uid = inUid
    AND
        e.ipAddr = inIpAddr
    AND
        e.nameId = n.id;

    DROP TEMPORARY TABLE IF EXISTS fetchSecurityNames;
END;

UPDATE dbMetadata SET value = '27' WHERE name = 'schema-patch-level';
