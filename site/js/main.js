var page = (window.location.hash != "" ? window.location.hash.substring(1) : "home");
var isScrolling = false;
var lockHistory = false;
var temp = false;
var oldScroll = 0;
// masiv s obekti, opisvashti poziciite, razmerite i zavyrtaneto na asteroidite za sekciq "Za proekta"
var pos = [{x:195.5, y:-300, size:207, rot:0}, {x:-545.5, y:170, size:100, rot:260}];

$(function() {
	
	// s pomoshtta na history.js obvyrzvam javascript-a sys sybitiq za promqna na url adresa (promqna na 
	// teksta sled reshetkata (#home, #demo i t.n.))
	$.History.bind(function(state) {	
	
		if(lockHistory) {
			lockHistory = false;
			return;
		}
		// ako teksta sled reshetkata e validen adres (ne e proizvolno vyveden tekst ot potrebitelq), 
		// skrolva do syotvetnata stranica
		if($("#"+state+"_cont").length) {
			
			$('li a[href$="'+page+'"]').removeClass("current");
			page = state;
			// tazi funkciq osyshtestvqva skrolvaneto
			scrollToPage(500);
			temp = isScrolling;
			isScrolling = true;
		}
	});
	
	// dobavqme i slushatel na sybitie pri rychno skrolvane
	// izpolzvame go, za da promenqme adresa na stranicata (napr. ako sme v sekciq "Nachalo" i skrolvame prodyljitelno nadolu, ot #home adresa shte stane #info, kakto i butona ot lqvoto meniu shte se ocveti v rozovo)
	$(window).scroll(function () {
	
		if(isScrolling)
			return;
		
		$(".slide").each(function() {
			var $this = $(this);
			var dist = ($this.offset().top  - $(window).scrollTop());
			var id = $this.attr('id');
			id = id.substr(0, id.indexOf('_'));
			
			if(window.location.hash != "#"+id && dist > $(window).height()*0.5 - $this.height() && dist < $(window).height()*0.5 ) {
				$('li a[href$="'+page+'"]').removeClass("current");
				page = id;
				$('li a[href$="'+page+'"]').addClass("current");
				window.location.hash = "#"+page;
				lockHistory = true;
			}
		});
	});
	
	// dobqvqme slushatel za orazmerqvane na prozoreca
	// nujen ni e za preizchisleniq
	$(window).resize(function() {
		calcHeight();
		scrollToPage(0);
		positionAsteroids();
	});
	
	// dobavqme asteroidite, izpolzvaiki informaciqta ot masiva "pos"
	var str = "";
	for(var i=0; i<pos.length; i++) str += "<img class=\"asteroid\" width=\"100\" src=\"assets/img/asteroid.png\" />";
	$("#info_cont").append(str);
	
	// umishleno izvikvame resize(), za da se izvika i funkciqta-slushatel, definirana po-gore
	$(window).resize();
	
	// pri natiskane na nqkoe ot dvete kopcheta za izteglqne v sekciqta "Iztegli" ni informira, che 
	// prilojenieto vse oshte ne e oficialno pusnato
	$(".download").click(function(e){
		alert("Приложението все още не е официално пуснато!");	
	});
	
	// pri natiskane na linka za resursi se poqvqva prompt s izbroeni linkove kym izpolzvanite resursi
	// prompt e, za da moje da se selektira (v Chrome pri Windows 7 alert-ite ne mogat da se selektirat)
	$("#resources, #resources2").click(function (e){
		prompt("Ресурси за сайта:", "http://1.usa.gov/qInp25 , http://1.usa.gov/10PirUQ , http://bit.ly/161m8iQ , http://bit.ly/11uWlhW");	
	})
});

// tazi funkciq otgovarq za pozicioniraneto na asteroidite
function positionAsteroids() {
	$(".asteroid").each(function(i) {
		$this = $(this);
		$this.rotate(pos[i].rot);
		$this.attr("width", pos[i].size+'px');
		$this.css('left', (pos[i].x+$(window).width()*0.5)+'px');
		$this.css('top', (pos[i].y+$(window).height()*0.5)+'px');
	});
}

// tazi funkciq predvaritelno izchislqva visochinata na vseki ekran - vseki ekran e s visochinata na viewport-a na brauzyra
function calcHeight() {
	var screenHeight = $(window).height();
	$("#home_cont").height(screenHeight);
	$("#info_cont").height(screenHeight);
	//$("#demo_cont").height(1080);
	$("#download_cont").height(screenHeight);
	$("#help_cont").height(screenHeight);
	
	// ako zaradi media query-tata sme skrili lqvoto meniu (tova stava pri malkite ekrani), preizchislqvame shirinata na vseki "slaid" (ekran)
	if($("#left_menu").is(":visible"))
		$(".slide").width($(window).width() - $("#left_menu").width());
	else
		$(".slide").width($(window).width());
}

// blagodarenie na scrollTo.js, efektnoto skrolirane iz stranicata stava izkliuchitelno lesno
function scrollToPage(duration) {
	$('li a[href$="'+page+'"]').addClass("current");

	var b = page=="home" || page=="demo" || $(window).height() > 430;
	var topOffset = (b ? ($("#"+page+"_cont").height()-$(window).height())*0.5 : 0);

	$("body").scrollTo("#"+page+"_cont", {duration: duration, offset:{top: topOffset }, easing:'swing', onAfter: function(){
		if(!temp)
			isScrolling = false;
		temp = true;
	}});
}