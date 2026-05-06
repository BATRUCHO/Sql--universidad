import customtkinter as ctk
from DB_CONFIG import COLORS, TABS
from Conexion import LoginScreen
from Tabla import TablePanel


class App(ctk.CTk):
    """Ventana principal con navegación por tabs."""

    def __init__(self):
        super().__init__()
        self.title("Clínica Veterinaria — Sistema de Gestión")
        self.geometry("1100x680")
        self.minsize(800, 500)
        self.configure(fg_color=COLORS["bg"])
        self.db = None
        self._show_login()

    #  Navegación de pantallas 
    def _show_login(self):
        for w in self.winfo_children():
            w.destroy()
        LoginScreen(self, on_connect=self._launch_app)

    def _launch_app(self, db):
        self.db = db
        for w in self.winfo_children():
            w.destroy()
        self._build_main()

    #  Pantalla principal 
    def _build_main(self):
        #  Header 
        header = ctk.CTkFrame(self, fg_color=COLORS["accent"],
                              corner_radius=0, height=56)
        header.pack(fill="x")
        header.pack_propagate(False)

        ctk.CTkLabel(header, text="🐾  Clínica Veterinaria",
                     font=ctk.CTkFont("Courier New", 18, "bold"),
                     text_color="white").pack(side="left", padx=20)

        ctk.CTkButton(header, text="⏻ Salir", width=90, height=32,
                      fg_color="white", text_color=COLORS["accent"],
                      hover_color="#dce8ff",
                      font=ctk.CTkFont("Courier New", 11, "bold"),
                      command=self._disconnect).pack(side="right", padx=16)

        # Barra de tabs
        tab_bar = ctk.CTkFrame(self, fg_color=COLORS["panel"],
                               corner_radius=0, height=48)
        tab_bar.pack(fill="x")
        tab_bar.pack_propagate(False)

        self.tab_buttons = {}

        # 🔥 Agregamos icono para bitácora
        icons = {
            "CLIENTE": "👥",
            "FACTURA": "🧾",
            "MASCOTA": "🐾",
            "BITACORA_CLIENTES": "📊"
        }

        for table in TABS:
            btn = ctk.CTkButton(
                tab_bar,
                text=f"  {icons.get(table, '📋')}  {table}  ",
                height=48,
                corner_radius=0,
                fg_color="transparent",
                hover_color=COLORS["card"],
                text_color=COLORS["subtext"],
                font=ctk.CTkFont("Courier New", 13, "bold"),
                command=lambda t=table: self._switch_tab(t)
            )
            btn.pack(side="left")
            self.tab_buttons[table] = btn

        # Área de contenido
        self.content = ctk.CTkFrame(self, fg_color=COLORS["bg"], corner_radius=0)
        self.content.pack(fill="both", expand=True)

        # Abrir primer tab por defecto
        self._switch_tab(TABS[0])

    def _switch_tab(self, table):
        # Resaltar tab activo
        for t, btn in self.tab_buttons.items():
            if t == table:
                btn.configure(fg_color=COLORS["bg"], text_color=COLORS["accent"])
            else:
                btn.configure(fg_color="transparent", text_color=COLORS["subtext"])

        # Cargar panel de tabla
        for w in self.content.winfo_children():
            w.destroy()

        TablePanel(self.content, table, self.db).pack(fill="both", expand=True)

    def _disconnect(self):
        if self.db:
            self.db.disconnect()
        self._show_login()


if __name__ == "__main__":
    app = App()
    app.mainloop()