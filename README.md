# Pharmacy

A simple Pharmacy Script for fivem which uses prescriptions

## Dependecies
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [qb-core](https://github.com/qbcore-framework/qb-core)

## Installation

- Add this to `ox_inventory\data\items.lua`
```lua
	['prescription'] = {
		label = 'Prescription',
		weight = 300,
		stack = false,
		close = true,
		description = "A piece of paper used for pharmacies"
	},
	['prescriptionpad'] = {
		label = 'Prescription Pad',
		weight = 300,
		stack = false,
		close = true,
		description = "A prescription pad used by doctors to write prescriptions"
	},
```
- Drop resource into your server directory and add `ensure rj-pharmacy` to your `server.cfg`
- Enjoy

## Original Script
	r14-rx
