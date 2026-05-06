import customtkinter as ctk

#  CONFIGURACIÓN DE CONEXIÓN
DB_CONFIG = {
    "user":            "UFPROY01",
    "password":        "palabraPaso2026",
    "dsn":             "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-chicago-1.oraclecloud.com))(connect_data=(service_name=g9f6e93ddc384d9_tjyzlbyxuwrrpkbb_medium.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))",
    "config_dir":      r"C:\Users\braya\Documents\GitHub\Sql -universidad\SQL\LlavesOracleSQL\Wallet_TJYZLBYXUWRRPKBB",
    "wallet_location": r"C:\Users\braya\Documents\GitHub\Sql -universidad\SQL\LlavesOracleSQL\Wallet_TJYZLBYXUWRRPKBB",
    "wallet_password": "BbA2025@@1025105",
}

# 🔥 AGREGAMOS BITÁCORA AQUÍ
TABS = ["CLIENTE", "FACTURA", "MASCOTA", "BITACORA_CLIENTES"]

TABLE_OWNERS = {
    "CLIENTE": "TABLAS_CLIENTES",
    "FACTURA": "TABLAS_FACTURACION",
    "MASCOTA": "TABLAS_MASCOTAS",
    "BITACORA_CLIENTES": "TABLAS_CLIENTES"  # 👈 IMPORTANTE
}

TABLE_COLUMNS = {
    "CLIENTE": ["IDCLIENTE", "NOMBRE", "APELLIDO", "FECHAREGISTRO", "IDTIPOCLIENTE"],
    "FACTURA": ["IDFACTURA", "FECHA", "IDCLIENTE"],
    "MASCOTA": ["IDMASCOTA", "NOMBRE", "FECHANACIMIENTO", "IDCLIENTE", "IDRAZA"],

    # 🔥 BITÁCORA
    "BITACORA_CLIENTES": [
        "IDBITACORA",
        "IDCLIENTE",
        "USUARIO_BD",
        "ACCION",
        "FECHA"
    ]
}

TABLE_PK = {
    "CLIENTE": "IDCLIENTE",
    "FACTURA": "IDFACTURA",
    "MASCOTA": "IDMASCOTA",
    "BITACORA_CLIENTES": "IDBITACORA"
}

DATE_COLUMNS = {"FECHA", "FECHAREGISTRO", "FECHANACIMIENTO"}

#  TEMA Y COLORES
ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("blue")

COLORS = {
    "bg":      "#0f1117",
    "panel":   "#1a1d27",
    "card":    "#22263a",
    "accent":  "#4f8ef7",
    "accent2": "#7c5cbf",
    "success": "#2ecc71",
    "danger":  "#e74c3c",
    "warning": "#f39c12",
    "text":    "#e8eaf0",
    "subtext": "#8892a4",
    "border":  "#2e3347",
}