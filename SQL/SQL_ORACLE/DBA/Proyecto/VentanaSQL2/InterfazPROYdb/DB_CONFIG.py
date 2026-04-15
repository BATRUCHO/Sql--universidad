import customtkinter as ctk

#  CONFIGURACIÓN DE CONEXIÓN
#  CONFIGURACIÓN DE CONEXIÓN ACTUALIZADA
DB_CONFIG = {
    "user":            "USRCONSULTA",
    "password":        "PwUsrNova24_Segura!",
    "dsn":             "(description=(retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-chicago-1.oraclecloud.com))(connect_data=(service_name=g9f6e93ddc384d9_k5iumdps5w2vkgy0_high.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes))(connect_timeout=60)(transport_connect_timeout=60))",
    "config_dir":      r"C:\Users\braya\Documents\GitHub\Sql -universidad\SQL\LlavesOracleSQL\Wallet_K5IUMDPS5W2VKGY0",
    "wallet_location": r"C:\Users\braya\Documents\GitHub\Sql -universidad\SQL\LlavesOracleSQL\Wallet_K5IUMDPS5W2VKGY0",
    "wallet_password": "BbA2025@@1025105",
}

#  TABLAS VISIBLES EN LA APP
# He ajustado los nombres para que coincidan con tus tablas reales
#  TABLAS VISIBLES EN LA APP
# Nota: Deben coincidir con los nombres en el script 02
TABS = ["DIM_CLIENTE", "DIM_SUCURSAL", "FACT_PRODUCTO_CONTRATO", "VW_CLIENTE_SEGURA"]

TABLE_OWNERS = {
    "DIM_CLIENTE": "DW_BANCO_NOVA",
    "DIM_SUCURSAL": "DW_BANCO_NOVA",
    "FACT_PRODUCTO_CONTRATO": "DW_BANCO_NOVA",
    "VW_CLIENTE_SEGURA": "DW_BANCO_NOVA",
}

TABLE_COLUMNS = {
    # Corregido: En tu SQL es ID_CLIENTE, no IDCLIENTE
    "DIM_CLIENTE": ["ID_CLIENTE", "NOMBRE", "APELLIDO", "TELEFONO", "EMAIL", "DNI"],
    
    # Corregido: En tu SQL es ID_SUCURSAL y NOMBRESUCURSAL
    "DIM_SUCURSAL": ["ID_SUCURSAL", "NOMBRESUCURSAL", "TELEFONO","DIM_TERRITORIO_ID_ZONA"],
    
    # Corregido: Estas son las columnas reales de tu tabla de hechos
    "FACT_PRODUCTO_CONTRATO": ["ID_CONTRATO", "MONTO_CONTRATO", "TASA_APLICADA", "SALDO_INICIAL", "PLAZOS_MESES"],
    
    # Esta es la vista del Archivo 03
    "VW_CLIENTE_SEGURA": ["ID_CLIENTE", "NOMBRE", "APELLIDO", "DNI", "NUMERO_TARJETA_CREDITO", "CUENTA_BANCARIA"]
}

TABLE_PK = {
    "DIM_CLIENTE": "ID_CLIENTE",
    "DIM_SUCURSAL": "ID_SUCURSAL",
    "FACT_PRODUCTO_CONTRATO": "ID_CONTRATO",
    "VW_CLIENTE_SEGURA": "ID_CLIENTE",
}

# Asegúrate de incluir aquí todas las columnas que Oracle devuelve como tipo DATE
DATE_COLUMNS = {"FECHA_NACIMIENTO", "FECHA_CONTRATACION"}

#  TEMA Y COLORES (Estilo Bancario Moderno)
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