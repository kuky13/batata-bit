extends Node

# Idioma atual ("en", "pt", "es")
var current_language: String = "pt"

# Dicionário com todas as strings do jogo
var TEXTS = {
	"pt": {
				"MAIN_TITLE": "Batata",
		"MAIN_PLAY": "Jogar",
		"MAIN_QUIT": "Sair",
		
		"CREATE_TITLE": "Criar um novo mundo",
		"CREATE_SEED_LABEL": "Seed (Deixe em branco para gerar uma)",
		"CREATE_SEED_PLACEHOLDER": "Coloque a seed...",
		"CREATE_GENERATE": "Criar mundo",
		"CREATE_BACK": "Voltar",
		
		"PAUSE_TITLE": "Pause",
		"PAUSE_RESUME": "Voltar",
		"PAUSE_SAVE": "Salvar mundo",
		"PAUSE_SAVED": "Mundo salvp!",
		"PAUSE_QUIT": "Ir para menu",
		
		"MOBILE_JUMP": "P",
		"MOBILE_PLACE": "+",
		"MOBILE_REMOVE": "-",
		"MOBILE_PAUSE": "||"

	},
}

func get_text(key: String) -> String:
	if TEXTS.has(current_language) and TEXTS[current_language].has(key):
		return TEXTS[current_language][key]
	elif TEXTS.has("en") and TEXTS["en"].has(key):
		return TEXTS["en"][key]
	return key
