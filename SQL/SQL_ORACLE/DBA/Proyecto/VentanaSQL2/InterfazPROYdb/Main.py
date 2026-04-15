import customtkinter as ctk
from DB_CONFIG import COLORS, TABS
from Conexion import LoginScreen
from Tabla import TablePanel

class App(ctk.CTk):
    """Ventana principal de Nova Bank - Inteligencia de Negocios."""

    def __init__(self):
        super().__init__()
        # 1. Identidad de marca
        self.title("Nova Bank BI — Panel de Control Financiero")
        self.geometry("1200x720") # Un poco más ancha para reportes financieros
        self.minsize(900, 600)
        self.configure(fg_color=COLORS["bg"])
        
        self.db = None
        self._show_login()

    def _show_login(self):
        """Limpia la pantalla y muestra el acceso."""
        for w in self.winfo_children():
            w.destroy()
        LoginScreen(self, on_connect=self._launch_app)

    def _launch_app(self, db):
        """Recibe la conexión exitosa y lanza la interfaz principal."""
        self.db = db
        for w in self.winfo_children():
            w.destroy()
        self._build_main()

    def _build_main(self):
        """Construye el layout principal: Header + Sidebar + Content."""
        
        # --- HEADER SUPERIOR ---
        header = ctk.CTkFrame(self, fg_color=COLORS["accent"], corner_radius=0, height=60)
        header.pack(fill="x")
        header.pack_propagate(False)

        ctk.CTkLabel(header, text="🏦  NOVA BANK | DATA WAREHOUSE",
                     font=ctk.CTkFont("Courier New", 18, "bold"),
                     text_color="white").pack(side="left", padx=20)

        ctk.CTkButton(header, text="Cerrar Sesión ⏻", 
                      width=140, height=32,
                      fg_color="transparent", border_width=1,
                      border_color="white",
                      hover_color=COLORS["danger"],
                      command=self._disconnect).pack(side="right", padx=20)

        # --- BARRA DE NAVEGACIÓN (TABS) ---
        tab_bar = ctk.CTkFrame(self, fg_color=COLORS["panel"], corner_radius=0, height=50)
        tab_bar.pack(fill="x")

        self.tab_buttons = {}
        # Iconos financieros para los tabs
        icons = {
            "CLIENTES": "👤",
            "CONTRATOS": "📄",
            "SUCURSALES": "📍",
            "REPORTE_BI": "📊" # Este es el más importante para tu proyecto
        }

        for table in TABS:
            btn = ctk.CTkButton(tab_bar, 
                                text=f"  {icons.get(table, '📋')}  {table}  ",
                                height=50, corner_radius=0,
                                fg_color="transparent",
                                hover_color=COLORS["card"],
                                text_color=COLORS["subtext"],
                                font=ctk.CTkFont("Courier New", 13, "bold"),
                                command=lambda t=table: self._switch_tab(t))
            btn.pack(side="left")
            self.tab_buttons[table] = btn

        # --- ÁREA DE CONTENIDO DINÁMICO ---
        self.content = ctk.CTkFrame(self, fg_color=COLORS["bg"], corner_radius=0)
        self.content.pack(fill="both", expand=True)

        # Mostrar por defecto el primer tab
        if TABS:
            self._switch_tab(TABS[0])

    def _switch_tab(self, table):
        """Cambia el panel de datos según el tab seleccionado."""
        # Resaltar botón activo
        for t, btn in self.tab_buttons.items():
            if t == table:
                btn.configure(fg_color=COLORS["bg"], text_color=COLORS["accent"])
            else:
                btn.configure(fg_color="transparent", text_color=COLORS["subtext"])

        # Limpiar y cargar panel de tabla
        for w in self.content.winfo_children():
            w.destroy()
        
        # TablePanel cargará los datos usando el USRCONSULTA
        TablePanel(self.content, table, self.db).pack(fill="both", expand=True)

    def _disconnect(self):
        """Cierra la conexión y vuelve al login."""
        if self.db:
            self.db.disconnect()
        self._show_login()

if __name__ == "__main__":
    app = App()
    app.mainloop()

