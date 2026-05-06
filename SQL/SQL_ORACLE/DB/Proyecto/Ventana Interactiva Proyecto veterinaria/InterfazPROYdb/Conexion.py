import customtkinter as ctk
from DB_CONFIG import DB_CONFIG, COLORS
from OracleDB import OracleDB


class LoginScreen(ctk.CTkFrame):
    """Pantalla de inicio de sesión."""

    def __init__(self, parent, on_connect):
        super().__init__(parent, fg_color=COLORS["bg"])
        self.on_connect = on_connect
        self._build()

    def _build(self):
        self.pack(fill="both", expand=True)

        center = ctk.CTkFrame(self, fg_color="transparent")
        center.place(relx=0.5, rely=0.5, anchor="center")

        ctk.CTkLabel(center, text="🐾", font=ctk.CTkFont(size=56)).pack(pady=(0, 4))
        ctk.CTkLabel(center, text="CLÍNICA VETERINARIA",
                     font=ctk.CTkFont("Courier New", 24, "bold"),
                     text_color=COLORS["accent"]).pack()
        ctk.CTkLabel(center, text="Sistema de Gestión",
                     font=ctk.CTkFont("Courier New", 12),
                     text_color=COLORS["subtext"]).pack(pady=(2, 24))

        card = ctk.CTkFrame(center, fg_color=COLORS["panel"],
                            corner_radius=16, border_width=1,
                            border_color=COLORS["border"])
        card.pack(ipadx=20, ipady=16)

        # Usuario
        ctk.CTkLabel(card, text="Usuario Oracle",
                     font=ctk.CTkFont("Courier New", 11),
                     text_color=COLORS["subtext"]).pack(anchor="w", padx=20, pady=(16, 0))
        self.user_entry = ctk.CTkEntry(card, width=300, height=36,
                                       font=ctk.CTkFont("Courier New", 13),
                                       fg_color=COLORS["card"],
                                       border_color=COLORS["border"])
        self.user_entry.pack(padx=20)
        self.user_entry.insert(0, DB_CONFIG["user"])

        # Contraseña
        ctk.CTkLabel(card, text="Contraseña",
                     font=ctk.CTkFont("Courier New", 11),
                     text_color=COLORS["subtext"]).pack(anchor="w", padx=20, pady=(12, 0))
        self.pass_entry = ctk.CTkEntry(card, width=300, height=36,
                                       font=ctk.CTkFont("Courier New", 13),
                                       fg_color=COLORS["card"],
                                       border_color=COLORS["border"],
                                       show="•")
        self.pass_entry.pack(padx=20)

        self.status_label = ctk.CTkLabel(card, text="",
                                          font=ctk.CTkFont("Courier New", 11),
                                          text_color=COLORS["warning"])
        self.status_label.pack(pady=(8, 0))

        ctk.CTkButton(card, text="  Conectar a Oracle  →",
                      width=300, height=40,
                      font=ctk.CTkFont("Courier New", 13, "bold"),
                      fg_color=COLORS["accent"], hover_color="#3a7de0",
                      command=self._try_connect).pack(padx=20, pady=(8, 20))

    def _try_connect(self):
        DB_CONFIG["user"]     = self.user_entry.get().strip()
        DB_CONFIG["password"] = self.pass_entry.get().strip()
        DB_CONFIG["dsn"]      = DB_CONFIG["dsn"]

        self.status_label.configure(text="Conectando...", text_color=COLORS["warning"])
        self.update()

        db = OracleDB()
        ok, msg = db.connect()
        if ok:
            self.status_label.configure(text="✓ Conexión exitosa", text_color=COLORS["success"])
            self.after(600, lambda: self.on_connect(db))
        else:
            self.status_label.configure(text=f"✗ {msg[:80]}", text_color=COLORS["danger"])