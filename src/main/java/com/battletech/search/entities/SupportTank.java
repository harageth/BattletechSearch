package com.battletech.search.entities;

import jakarta.persistence.Entity;

// MegaMek's "SupportTank" and "LargeSupportTank": trucks, APCs, MASH trucks, boats. A tank to a search
// ("tanks", "tracked"), unless it asks for combat vehicles (user, 2026-11-15)
@Entity
public class SupportTank extends Tank {
}
