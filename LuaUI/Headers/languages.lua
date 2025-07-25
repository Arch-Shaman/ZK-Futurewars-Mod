local langs = {
	{ lang = 'en', flag = 'gb', name = 'English' },
	{ lang = 'ru', flag = 'ru', name = 'Русский' },
	{ lang = 'pl', flag = 'pl', name = 'Polski' },
	{ lang = 'it', flag = 'it', name = 'Italiano' },
	{ lang = 'de', flag = 'de', name = 'Deutsch' },
	{ lang = 'tr', flag = 'tr', name = 'Türkçe' },
	{ lang = 'zh', flag = 'cn', name = '簡體中文' },
	{ lang = 'ja', flag = 'jp', name = '日本語'},
	{ lang = 'fr', flag = 'fr', name = 'Français'},
	{ lang = 'pt', flag = 'pt', name = 'Português'},
--	{ lang = 'zh_TW', flag = 'tw', name = '繁體中文' }, -- currently unsupported, needs massive re-translation
	{ lang = 'th', flag = 'th', name = "ภาษาไทย"},
	{ lang = 'vi', flag = 'vn', name = "tiếng Việt"},
}

local flagByLang, langByFlag = {}, {}
for i = 1, #langs do
	local x = langs[i]
	flagByLang[x.lang] = x.flag
	langByFlag[x.flag] = x.lang
end

setmetatable(langByFlag, { __index = function()
	return 'en'
end})

return langs, flagByLang, langByFlag