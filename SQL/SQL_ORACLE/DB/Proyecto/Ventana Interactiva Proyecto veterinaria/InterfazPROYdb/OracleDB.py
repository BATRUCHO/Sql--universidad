import oracledb
from DB_CONFIG import DB_CONFIG, TABLE_OWNERS, TABLE_COLUMNS, TABLE_PK


class OracleDB:
    """Maneja la conexión y operaciones contra Oracle ADB."""

    def __init__(self):
        self.conn = None

    def connect(self):
        """Retorna (True, msg) o (False, msg)."""
        try:
            self.conn = oracledb.connect(**DB_CONFIG)

            # 🔥 Enviar el usuario de la app a Oracle (para la bitácora)
            cursor = self.conn.cursor()
            cursor.execute(
                "BEGIN DBMS_SESSION.SET_IDENTIFIER(:1); END;",
                [DB_CONFIG["user"]]
            )
            cursor.close()

            return True, "Conexión exitosa"
        except Exception as e:
            return False, str(e)

    def disconnect(self):
        if self.conn:
            self.conn.close()
            self.conn = None

    def fetch_all(self, table: str) -> list:
        """Trae todos los registros de la tabla ordenados por PK."""
        owner  = TABLE_OWNERS[table]
        cols   = ", ".join(TABLE_COLUMNS[table])
        sql    = f"SELECT {cols} FROM {owner}.{table} ORDER BY 1"
        cursor = self.conn.cursor()
        cursor.execute(sql)
        rows = cursor.fetchall()
        cursor.close()
        return rows

    def insert(self, table: str, values: dict):
        """Inserta un registro. values = {columna: valor, ...}"""
        owner        = TABLE_OWNERS[table]
        cols         = list(values.keys())
        placeholders = [f":{i+1}" for i in range(len(cols))]
        sql = (f"INSERT INTO {owner}.{table} "
               f"({', '.join(cols)}) VALUES ({', '.join(placeholders)})")
        cursor = self.conn.cursor()
        cursor.execute(sql, list(values.values()))
        self.conn.commit()
        cursor.close()

    def get_next_id(self, table: str) -> int:
        """Retorna MAX(PK)+1 para sugerir el próximo ID."""
        owner  = TABLE_OWNERS[table]
        pk     = TABLE_PK[table]
        cursor = self.conn.cursor()
        cursor.execute(f"SELECT NVL(MAX({pk}), 0) + 1 FROM {owner}.{table}")
        val = cursor.fetchone()[0]
        cursor.close()
        return int(val)
    
    def delete(self, table: str, pk_value):
        owner = TABLE_OWNERS[table]
        pk    = TABLE_PK[table]

        cursor = self.conn.cursor()
        cursor.execute(
            f"DELETE FROM {owner}.{table} WHERE {pk} = :1",
            [pk_value]
        )
        self.conn.commit()
        cursor.close()

    def update(self, table: str, values: dict, pk_value):
        owner = TABLE_OWNERS[table]
        pk    = TABLE_PK[table]

        cols = [col for col in values.keys() if col != pk]

        processed_values = []
        for col in cols:
            val = values[col]

            # 🔥 Convertir fechas si vienen como string
            if isinstance(val, str) and "-" in val:
                try:
                    from datetime import datetime
                    val = datetime.strptime(val, "%Y-%m-%d")
                except:
                    pass

            # 🔥 Convertir números si aplica
            if isinstance(val, str) and val.isdigit():
                val = int(val)

            processed_values.append(val)

        set_clause = ", ".join([f"{col} = :{i+1}" for i, col in enumerate(cols)])
        sql = f"UPDATE {owner}.{table} SET {set_clause} WHERE {pk} = :{len(cols)+1}"

        params = processed_values + [pk_value]

        cursor = self.conn.cursor()
        cursor.execute(sql, params)
        self.conn.commit()
        cursor.close()