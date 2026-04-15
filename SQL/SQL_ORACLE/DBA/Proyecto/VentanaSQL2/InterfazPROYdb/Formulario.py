import tkinter as tk
from tkinter import messagebox
import customtkinter as ctk
from datetime import datetime
from DB_CONFIG import COLORS, TABLE_COLUMNS, TABLE_PK, DATE_COLUMNS


class FormDialog(ctk.CTkToplevel):
    """Ventana modal para insertar un nuevo registro."""

    def __init__(self, parent, table, db):
        super().__init__(parent)
        self.table   = table
        self.db      = db
        self.result  = None
        self.entries = {}

        self.title(f"Nuevo registro — {table}")
        self.geometry("460x500")
        self.resizable(False, False)
        self.configure(fg_color=COLORS["panel"])
        self.grab_set()

        self._build()

    def _build(self):
        cols = TABLE_COLUMNS[self.table]
        pk   = TABLE_PK[self.table]

        # Encabezado
        header = ctk.CTkFrame(self, fg_color=COLORS["accent"], corner_radius=0, height=48)
        header.pack(fill="x")
        header.pack_propagate(False)
        ctk.CTkLabel(header, text=f"  ➕  Insertar en {self.table}",
                     font=ctk.CTkFont("Courier New", 14, "bold"),
                     text_color="white").pack(side="left", padx=12)

        # Campos con scroll
        scroll = ctk.CTkScrollableFrame(self, fg_color=COLORS["panel"])
        scroll.pack(fill="both", expand=True, padx=20, pady=16)

        for col in cols:
            is_pk = (col == pk)

            ctk.CTkLabel(scroll, text=col + (" (PK)" if is_pk else ""),
                         font=ctk.CTkFont("Courier New", 11),
                         text_color=COLORS["accent"] if is_pk else COLORS["subtext"]
                         ).pack(anchor="w", pady=(6, 0))

            entry = ctk.CTkEntry(scroll, height=34,
                                 font=ctk.CTkFont("Courier New", 12),
                                 fg_color=COLORS["card"],
                                 border_color=COLORS["accent"] if is_pk else COLORS["border"],
                                 text_color=COLORS["text"])
            entry.pack(fill="x", pady=(2, 0))

            # Auto-completar y deshabilitar PK
            if is_pk:
                try:
                    entry.insert(0, str(self.db.get_next_id(self.table)))
                except Exception:
                    pass
                entry.configure(state="disabled", fg_color="#1a1f2e")

            if col in DATE_COLUMNS:
                ctk.CTkLabel(scroll, text="  formato: YYYY-MM-DD",
                             font=ctk.CTkFont("Courier New", 9),
                             text_color=COLORS["warning"]).pack(anchor="w")

            self.entries[col] = entry

        # Botones
        btn_frame = ctk.CTkFrame(self, fg_color=COLORS["panel"])
        btn_frame.pack(fill="x", padx=20, pady=12)

        ctk.CTkButton(btn_frame, text="✓  Guardar",
                      fg_color=COLORS["success"], hover_color="#27ae60",
                      font=ctk.CTkFont("Courier New", 13, "bold"),
                      command=self._save).pack(side="left", expand=True, padx=(0, 6))

        ctk.CTkButton(btn_frame, text="✕  Cancelar",
                      fg_color=COLORS["card"], hover_color=COLORS["danger"],
                      font=ctk.CTkFont("Courier New", 13),
                      command=self.destroy).pack(side="left", expand=True, padx=(6, 0))

    def _save(self):
        cols   = TABLE_COLUMNS[self.table]
        values = {}

        for col in cols:
            raw = self.entries[col].get().strip()
            if raw == "":
                values[col] = None
            elif col in DATE_COLUMNS:
                try:
                    values[col] = datetime.strptime(raw, "%Y-%m-%d")
                except ValueError:
                    messagebox.showerror("Error", f"Fecha inválida en {col}. Usa YYYY-MM-DD")
                    return
            else:
                try:
                    values[col] = int(raw) if ("ID" in col or col == "COSTO") else raw
                except ValueError:
                    values[col] = raw

        try:
            self.db.insert(self.table, values)
            messagebox.showinfo("Éxito", "Registro insertado correctamente ✓")
            self.result = True
            self.destroy()
        except Exception as e:
            messagebox.showerror("Error Oracle", str(e))