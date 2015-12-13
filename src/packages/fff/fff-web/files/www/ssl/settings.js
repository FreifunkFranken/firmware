
/*
All required uci packages are stored variable uci.
The GUI code displayes and manipulated this variable.
*/
var uci = {};
var gid = 0;


function init()
{
	send("/cgi-bin/settings", { func : "get_settings" }, function(data) {
		uci = fromUCI(data);
		rebuild_general();
		adv_apply();
	});
}

function updateFrom(src)
{
	var obj = {};
	collect_inputs(src, obj);
	for(var name in obj)
	{
		var value = obj[name];
		var path = name.split('#');

		var pkg = path[0];
		var sec = path[1];
		var opt = path[2];

		uci[pkg].pchanged = true;
		uci[pkg][sec][opt] = value;
	}
}

function getChangeModeAction(ifname)
{
	return function(e) {
		var src = (e.target || e.srcElement);
		var mode = (src.data || src.value);
		delNetSection(ifname);
		addNetSection(ifname, mode);
	};
}

function appendSetting(p, path, value, mode)
{
	var id = path.join('#');
	var b;
	var cfg = path[0];
	var name = path[path.length-1];
	switch(name)
	{
	case "geo":
		b = append_input(p, "GPS-Koordinaten", id, value);
		b.lastChild.placeholder = "52.02713078 8.52829987";
		addInputCheck(b.lastChild, /^$|^\d{1,3}\.\d{1,8} {1,3}\d{1,3}\.\d{1,8}$/, "Ung\xfcltige Eingabe. Bitte nur maximal 8 Nachkommastellen und keine Kommas verwenden.");
		addHelpText(b, "Die Koordinaten dieses Knotens auf der Freifunk-Karte (z.B. \"52.02713078 8.52829987\").");
		break;
	case "hostname":
		b = append_input(p, "Knotenname", id, value);
		b.lastChild.placeholder = "MeinRouter";
		addInputCheck(b.lastChild, /^$|^[\-\^'\w\.\:\[\]\(\)\/ &@\+\u0080-\u00FF]{0,32}$/, "Ung\xfcltige Eingabe.");
		addHelpText(b, "Der Name dieses Knotens auf der Freifunk-Karte.");
		break;
	case "contact":
		b = append_input(p, "Kontaktdaten", id, value);
		b.lastChild.placeholder = "info@example.com";
		addInputCheck(b.lastChild, /^$|^[\-\^'\w\.\:\[\]\(\)\/ &@\+\u0080-\u00FF]{0,32}$/, "Ung\xfcltige Eingabe.");
		addHelpText(b, "Kontaktdaten f\xfcr die \xf6ffentliche Freifunk-Karte und Statusseite. Falls ihr euch von anderen Leuten kontaktieren lassen wollt (z.B. \"info@example.com\").");
		break;
	case "enabled":
		if(cfg == "simple-tc") {
			b = append_radio(p, "Bandbreitenkontrolle", id, value, [["An", "1"], ["Aus", "0"]]);
			addHelpText(b, "Bandbreitenkontrolle f\xfcr den Upload-/Download \xfcber das Freifunknetz \xfcber den eigenen Internetanschluss.");
		}
		break;
	case "limit_egress":
		b = append_input(p, "Freifunk Upload", id, value);
		addInputCheck(b.lastChild, /^\d+$/, "Upload ist ung\xfcltig.");
		addHelpText(b, "Maximaler Upload in KBit/s f\xfcr die Bandbreitenkontrolle.");
		break;
	case "limit_ingress":
		b = append_input(p, "Freifunk Download", id, value);
		addInputCheck(b.lastChild, /^\d+$/, "Download ist ung\xfcltig.");
		addHelpText(b, "Maximaler Download in KBit/s f\xfcr die Bandbreitenkontrolle.");
		break;
	default:
		return;
	}

	b.id = id; //needed for updateFrom
	b.onchange = function() {
		updateFrom(b);
	};

	return b;
}

function rebuild_general()
{
	var gfs = $("general");
	var tfs = $("traffic");

	removeChilds(gfs);
	removeChilds(tfs);

	if('system' in uci) {
		var f = uci['system'];
		var i = firstSectionID(f, "system");
		appendSetting(gfs, ['system', i, "hostname"], f[i]["hostname"]);
		appendSetting(gfs, ['system', i, "geo"], f[i]["geo"]);
		appendSetting(gfs, ['system', i, "contact"], f[i]["contact"]);
	}

	if('simple-tc' in uci) {
		var t = uci['simple-tc'];
		var i = firstSectionID(t, "interface");
		appendSetting(tfs, ['simple-tc', i, "enabled"], t[i]["enabled"]);
		appendSetting(tfs, ['simple-tc', i, "limit_ingress"], t[i]["limit_ingress"]);
		appendSetting(tfs, ['simple-tc', i, "limit_egress"], t[i]["limit_egress"]);
	}
}

function save_data()
{
	for(var name in uci)
	{
		var obj = uci[name];
		if(!obj.pchanged)
			continue;
		var data = toUCI(obj);
		send("/cgi-bin/misc", { func : "set_config_file", name : name, data : data },
			function(data) {
				$('msg').innerHTML = data;
				$('msg').focus();
				init();
			}
		);
	}
}
