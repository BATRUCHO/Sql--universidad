-- 1) Usuarios del proyecto
SELECT username, default_tablespace, temporary_tablespace
FROM dba_users
WHERE username LIKE 'TABLAS%'
   OR username LIKE 'DESA%'
   OR username LIKE 'UF%'
ORDER BY 1;

-- 2) Cuotas en los tablespaces
SELECT *
FROM dba_ts_quotas
WHERE username LIKE 'TABLAS%'
   OR username LIKE 'DESA%'
   OR username LIKE 'UF%'
ORDER BY 1;

-- 3) Privilegios de sistema de usuarios y roles del proyecto
SELECT *
FROM dba_sys_privs
WHERE grantee LIKE 'TABLAS%'
   OR grantee LIKE 'DESA%'
   OR grantee LIKE 'ROLDES%'
   OR grantee LIKE 'UF%'
   OR grantee LIKE 'ROLUF%'
ORDER BY 1;

-- 4) Listado completo de objetos creados (tablas, triggers, procedures, etc)
SELECT owner, object_name, object_type
FROM dba_objects
WHERE owner LIKE 'TABLAS%'
   OR owner LIKE 'DESA%'
   OR owner LIKE 'UF%'
ORDER BY 1, 3, 2;

-- 5) Privilegios sobre objetos (GRANT SELECT, INSERT, EXECUTE, etc)
SELECT *
FROM dba_tab_privs
WHERE grantee LIKE 'TABLAS%'
   OR grantee LIKE 'DESA%'
   OR grantee LIKE 'ROLDES%'
   OR grantee LIKE 'UF%'
   OR grantee LIKE 'ROLUF%'
ORDER BY 1;

-- 6) Roles del proyecto
SELECT *
FROM dba_roles
WHERE role LIKE 'ROLDES%'
   OR role LIKE 'ROLUF%';

-- 7) Asignacion de roles a usuarios
SELECT *
FROM dba_role_privs
WHERE granted_role LIKE 'ROLDES%'
   OR granted_role LIKE 'ROLUF%'
ORDER BY 2;
