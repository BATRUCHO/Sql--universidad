import customtkinter as ctk
from DB_CONFIG import DB_CONFIG, COLORS
from OracleDB import OracleDB

class LoginScreen(ctk.CTkFrame):
    """Pantalla de inicio de sesión para Nova Bank BI."""

    def __init__(self, parent, on_connect):
        super().__init__(parent, fg_color=COLORS["bg"])
        self.on_connect = on_connect
        self._build()
        

    def _build(self):
        self.pack(fill="both", expand=True)

        center = ctk.CTkFrame(self, fg_color="transparent")
        center.place(relx=0.5, rely=0.5, anchor="center")

        # Icono y Título Bancario
        ctk.CTkLabel(center, text="🏦", font=ctk.CTkFont(size=60)).pack(pady=(0, 10))
        ctk.CTkLabel(center, text="NOVA BANK BI",
                     font=ctk.CTkFont("Courier New", 26, "bold"),
                     text_color=COLORS["accent"]).pack()
        ctk.CTkLabel(center, text="Business Intelligence System",
                     font=ctk.CTkFont("Courier New", 13),
                     text_color=COLORS["subtext"]).pack(pady=(2, 30))

        # Tarjeta de Login
        card = ctk.CTkFrame(center, fg_color=COLORS["panel"],
                            corner_radius=16, border_width=1,
                            border_color=COLORS["border"])
        card.pack(ipadx=25, ipady=20)

        # Entrada de Usuario
        ctk.CTkLabel(card, text="Usuario Oracle",
                     font=ctk.CTkFont("Courier New", 12, "bold"),
                     text_color=COLORS["text"]).pack(anchor="w", padx=25, pady=(15, 5))
        
        self.user_entry = ctk.CTkEntry(card, width=320, height=40,
                               placeholder_text="Usuario (Ej: USRCONSULTA o DW_BANCO_NOVA)",
                               font=ctk.CTkFont("Courier New", 13))
        
        self.user_entry.pack(padx=25)

        # Entrada de Contraseña
        ctk.CTkLabel(card, text="Contraseña",
                     font=ctk.CTkFont("Courier New", 12, "bold"),
                     text_color=COLORS["text"]).pack(anchor="w", padx=25, pady=(15, 5))
        
        self.pass_entry = ctk.CTkEntry(card, width=320, height=40,
                               placeholder_text="Ingrese su contraseña",
                               show="•")
        
        self.pass_entry.pack(padx=25)

        # Etiqueta de Estado
        self.status_label = ctk.CTkLabel(card, text="",
                                          font=ctk.CTkFont("Courier New", 11),
                                          text_color=COLORS["warning"])
        self.status_label.pack(pady=(12, 0))

        # Botón de Conexión
        ctk.CTkButton(card, text="  Acceder al Sistema  →",
                      width=320, height=45,
                      font=ctk.CTkFont("Courier New", 13, "bold"),
                      fg_color=COLORS["accent"], hover_color="#3a7de0",
                      command=self._try_connect).pack(padx=25, pady=(10, 25))

    def _try_connect(self):
        # Esto captura lo que TÚ escribas en la interfaz
        usuario_ingresado = self.user_entry.get().strip()
        clave_ingresada = self.pass_entry.get().strip()
        
        # Actualizamos la configuración global antes de conectar
        DB_CONFIG["user"] = usuario_ingresado
        DB_CONFIG["password"] = clave_ingresada

        self.status_label.configure(text="Iniciando sesión segura...", text_color=COLORS["warning"])
        self.update()

        db = OracleDB()
        ok, msg = db.connect()
        
        if ok:
            self.status_label.configure(text=f"✓ Bienvenido {usuario_ingresado}", text_color=COLORS["success"])
            self.after(800, lambda: self.on_connect(db))
        else:
            self.status_label.configure(text="Error: Credenciales inválidas", text_color=COLORS["danger"])