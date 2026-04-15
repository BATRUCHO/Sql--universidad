import tkinter as tk
from tkinter import ttk, messagebox
import customtkinter as ctk
from datetime import datetime
from DB_CONFIG import COLORS, TABLE_COLUMNS
from Formulario import FormDialog


class TablePanel(ctk.CTkFrame):
    """Panel que muestra registros en una tabla y permite insertar nuevos."""

    def __init__(self, parent, table, db):
        super().__init__(parent, fg_color=COLORS["bg"])
        self.table = table
        self.db    = db
        self._build()
        self.load_data()

    def _build(self):
        # Barra superior
        top = ctk.CTkFrame(self, fg_color=COLORS["panel"], corner_radius=10)
        top.pack(fill="x", padx=16, pady=(16, 8))

        ctk.CTkLabel(top, text=f"  📋  {self.table}",
                     font=ctk.CTkFont("Courier New", 16, "bold"),
                     text_color=COLORS["accent"]).pack(side="left", padx=12, pady=12)

        ctk.CTkButton(top, text="  ＋  Insertar registro", width=180, height=36,
                      fg_color=COLORS["success"], hover_color="#27ae60",
                      font=ctk.CTkFont("Courier New", 13, "bold"),
                      command=self._insert).pack(side="right", padx=12, pady=10)

        ctk.CTkButton(top, text="↺ Actualizar", width=120, height=36,
                      fg_color=COLORS["card"], hover_color=COLORS["border"],
                      font=ctk.CTkFont("Courier New", 12),
                      command=self.load_data).pack(side="right", padx=(0, 6), pady=10)

        # Treeview
        tree_frame = ctk.CTkFrame(self, fg_color=COLORS["panel"], corner_radius=10)
        tree_frame.pack(fill="both", expand=True, padx=16, pady=(0, 8))

        style = ttk.Style()
        style.theme_use("clam")
        style.configure("Custom.Treeview",
                        background=COLORS["card"],
                        foreground=COLORS["text"],
                        fieldbackground=COLORS["card"],
                        rowheight=30,
                        font=("Courier New", 11))
        style.configure("Custom.Treeview.Heading",
                        background=COLORS["accent"],
                        foreground="white",
                        font=("Courier New", 12, "bold"),
                        relief="flat")
        style.map("Custom.Treeview",
                  background=[("selected", COLORS["accent2"])],
                  foreground=[("selected", "white")])

        cols = TABLE_COLUMNS[self.table]
        self.tree = ttk.Treeview(tree_frame, columns=cols, show="headings",
                                 style="Custom.Treeview", selectmode="browse")
        for col in cols:
            self.tree.heading(col, text=col)
            self.tree.column(col, width=150, anchor="center")

        vsb = ttk.Scrollbar(tree_frame, orient="vertical",   command=self.tree.yview)
        hsb = ttk.Scrollbar(tree_frame, orient="horizontal", command=self.tree.xview)
        self.tree.configure(yscrollcommand=vsb.set, xscrollcommand=hsb.set)

        self.tree.grid(row=0, column=0, sticky="nsew", padx=(10, 0), pady=10)
        vsb.grid(row=0, column=1, sticky="ns",  pady=10)
        hsb.grid(row=1, column=0, sticky="ew",  padx=(10, 0))
        tree_frame.grid_rowconfigure(0, weight=1)
        tree_frame.grid_columnconfigure(0, weight=1)

        # Barra de estado
        self.status_var = tk.StringVar(value="Listo")
        ctk.CTkLabel(self, textvariable=self.status_var,
                     font=ctk.CTkFont("Courier New", 10),
                     text_color=COLORS["subtext"]).pack(anchor="w", padx=18, pady=(0, 8))

    def load_data(self):
        try:
            rows = self.db.fetch_all(self.table)
            for item in self.tree.get_children():
                self.tree.delete(item)
            for i, row in enumerate(rows):
                formatted = []
                for val in row:
                    if isinstance(val, datetime):
                        formatted.append(val.strftime("%Y-%m-%d"))
                    elif val is None:
                        formatted.append("—")
                    else:
                        formatted.append(str(val))
                self.tree.insert("", "end", values=formatted,
                                 tags=("odd",) if i % 2 else ())
            self.tree.tag_configure("odd", background="#1e2235")
            self.status_var.set(
                f"  {len(rows)} registros  •  {datetime.now().strftime('%H:%M:%S')}"
            )
        except Exception as e:
            messagebox.showerror("Error al cargar", str(e))

    def _insert(self):
        dlg = FormDialog(self, self.table, self.db)
        self.wait_window(dlg)
        if dlg.result:
            self.load_data()