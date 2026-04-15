import oracledb
from DB_CONFIG import DB_CONFIG, TABLE_OWNERS, TABLE_COLUMNS, TABLE_PK

class OracleDB:
    """Maneja la conexión y operaciones contra Oracle ADB para Banco Nova."""

    def __init__(self):
        self.conn = None

    def connect(self):
        try:
            self.conn = oracledb.connect(**DB_CONFIG)
            
            # NUEVO: Activar el rol explícitamente al conectar
            cursor = self.conn.cursor()
            cursor.execute("SET ROLE ROL_CONSULTA_APP")
            cursor.close()
            
            return True, "Conexión exitosa"
        except Exception as e:
            return False, f"Error: {str(e)}"

    def disconnect(self):
        if self.conn:
            self.conn.close()
            self.conn = None

    def fetch_all(self, table: str) -> list:
        try:
            owner = TABLE_OWNERS.get(table, "DW_BANCO_NOVA")
            cols = ", ".join(TABLE_COLUMNS[table])
            
            # Agregamos comillas dobles para forzar a Oracle a buscar el nombre exacto
            sql = f'SELECT {cols} FROM {owner}."{table}"'
            
            print(f"DEBUG SQL: {sql}") # Esto saldrá en tu terminal de VS Code
            
            cursor = self.conn.cursor()
            cursor.execute(sql)
            rows = cursor.fetchall()
            cursor.close()
            return rows
        except Exception as e:
            print(f"Error ejecutando: {table}")
            raise e

    def insert(self, table: str, values: dict):
        """Inserta un registro financiero en el esquema del dueño."""
        try:
            owner = TABLE_OWNERS[table]
            cols = list(values.keys())
            # Generamos :1, :2, etc. para evitar SQL Injection
            placeholders = [f":{i+1}" for i in range(len(cols))]
            
            sql = (f"INSERT INTO {owner}.{table} "
                   f"({', '.join(cols)}) VALUES ({', '.join(placeholders)})")
            
            cursor = self.conn.cursor()
            cursor.execute(sql, list(values.values()))
            self.conn.commit()
            cursor.close()
        except Exception as e:
            if self.conn:
                self.conn.rollback()
            raise e

    def get_next_id(self, table: str) -> int:
        """Calcula el siguiente ID si no usas secuencias automáticas."""
        try:
            owner = TABLE_OWNERS[table]
            pk = TABLE_PK[table]
            sql = f"SELECT MAX({pk}) FROM {owner}.{table}"
            
            cursor = self.conn.cursor()
            cursor.execute(sql)
            row = cursor.fetchone()
            cursor.close()
            
            return (row[0] + 1) if row[0] is not None else 1
        except Exception:
            return 1
