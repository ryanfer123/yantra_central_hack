import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import random


# --- 1. Define Models ---
class BatteryCell:
    def __init__(self, capacity_ah=50.0, nominal_voltage=3.7):
        self.capacity_ah = capacity_ah
        self.max_capacity = capacity_ah * random.uniform(0.99, 1.01)
        self.current_capacity = self.max_capacity * 0.9
        self.internal_res_mOhm = 2.0 * random.uniform(0.95, 1.05)
        self.voltage = nominal_voltage

    def update(self, current_amps, dt):
        removed_ah = (current_amps * dt) / 3600.0
        self.current_capacity -= removed_ah

        soc = self.current_capacity / self.max_capacity
        ocv = 3.0 + (1.2 * soc)
        v_drop = current_amps * (self.internal_res_mOhm / 1000.0)

        self.voltage = ocv - v_drop
        return self.voltage


class ElectricVehicleEnhanced:
    def __init__(self):
        self.mass = 1800
        self.drag_coeff = 0.24
        self.frontal_area = 2.3

        self.num_cells_series = 96
        self.cells = [BatteryCell() for _ in range(self.num_cells_series)]

        self.pack_voltage = 0.0
        self.pack_current = 0.0
        self.pack_soc = 90.0

        self.pack_temp = 25.0
        self.inverter_temp = 30.0
        self.coolant_flow = 0.0

        self.odometer = 0.0
        self.energy_consumed_kwh = 0.0
        self.regen_energy_kwh = 0.0
        self.insulation_resistance_mohm = 50.0

        self.velocity_ms = 0.0
        self.throttle_pos = 0.0

    def update(self, target_speed_kmh, dt=1.0):
        target_ms = target_speed_kmh / 3.6

        if target_ms > self.velocity_ms:
            self.throttle_pos = min((target_ms - self.velocity_ms) * 10, 100)
            accel = 2.0
        elif target_ms < self.velocity_ms:
            self.throttle_pos = 0
            accel = -2.0
        else:
            self.throttle_pos = 10
            accel = 0.0

        f_drag = 0.5 * 1.225 * self.drag_coeff * self.frontal_area * (self.velocity_ms ** 2)
        f_roll = 0.015 * self.mass * 9.81
        f_inertial = self.mass * accel

        total_force = f_drag + f_roll + f_inertial
        power_watts = total_force * self.velocity_ms

        self.pack_current = power_watts / 350.0

        cell_voltages = [cell.update(self.pack_current, dt) for cell in self.cells]
        self.pack_voltage = sum(cell_voltages)

        self.pack_soc = np.mean(
            [c.current_capacity / c.max_capacity for c in self.cells]
        ) * 100

        power_kw = (self.pack_voltage * self.pack_current) / 1000.0
        energy_step = (power_kw * dt) / 3600.0

        if power_kw > 0:
            self.energy_consumed_kwh += energy_step
        else:
            self.regen_energy_kwh -= energy_step

        heat_watts = (self.pack_current ** 2) * 0.05

        if self.pack_temp > 35:
            self.coolant_flow = 10.0
            cooling_watts = 2000
        else:
            self.coolant_flow = 0.0
            cooling_watts = 50

        temp_change = (heat_watts - cooling_watts) * dt / (450 * 795)

        self.pack_temp += temp_change
        self.inverter_temp += temp_change * 1.2

        self.insulation_resistance_mohm = 50.0 + random.uniform(-0.1, 0.1)

        c_rate_stress = abs(self.pack_current) / 200.0
        temp_stress = max(0, (self.pack_temp - 25) / 20)

        stress_index = min(10, max(0, (c_rate_stress * 5) + (temp_stress * 5)))

        self.velocity_ms += accel * dt
        if self.velocity_ms < 0:
            self.velocity_ms = 0

        self.odometer += (self.velocity_ms * dt) / 1000.0

        return {
            "Pack_Voltage": self.pack_voltage,
            "Pack_Current": self.pack_current,
            "Instant_Power": power_kw,
            "SoC": self.pack_soc,
            "Cell_Max": max(cell_voltages),
            "Cell_Min": min(cell_voltages),
            "Cell_Imbalance": max(cell_voltages) - min(cell_voltages),
            "Internal_Resistance": 0.05 + (0.001 * (100 - self.pack_soc) / 100),
            "Pack_Temp": self.pack_temp,
            "Inverter_Temp": self.inverter_temp,
            "Speed_kmh": self.velocity_ms * 3.6,
            "Stress_Index": stress_index,
        }


# --- 2. Run Simulation ---
sim = ElectricVehicleEnhanced()
data = []

for t in range(600):
    if t < 50:
        target = 30
    elif t < 150:
        target = 60
    elif t < 200:
        target = 0
    elif t < 400:
        target = 100
    elif t < 450:
        target = 0
    else:
        target = 40

    packet = sim.update(target, dt=1.0)
    packet["Time"] = t
    data.append(packet)

df = pd.DataFrame(data)
