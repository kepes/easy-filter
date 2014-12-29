//= require jquery
//= require jquery-ui

if (typeof Turbolinks !== 'undefined') {
  $(document).on("page:change", function () {
    init_easy_filter();
  });
} else {
  $(document).ready(function() {
    init_easy_filter();
  });
}

function init_easy_filter() {
  $('ul.easy-filter-dropdown li a').click(function (e) {
    html = $(this).html();
    $(this).parents('ul.easy-filter-dropdown').prev().children().first().remove();
    $(this).parents('ul.easy-filter-dropdown').prev().prepend(html);
    $(this).parents('div.easy-filter-dropdown').removeClass('open')
    $(this).parents('div.easy-filter-dropdown').find('input').first().val($(this).attr('data-target'));
  });
  $(".easy-filter-datepicker").datepicker($.datepicker.regional[ "hu" ]);
  $(".easy-filter-datepicker").each(function() { $(this).val($(this).attr('value')); });
}

/* Hungarian initialisation for the jQuery UI date picker plugin. */
/* Written by Peter Kepes (https://github.com/kepes),
*/
(function( factory ) {
	if ( typeof define === "function" && define.amd ) {

		// AMD. Register as an anonymous module.
		define([ "../jquery.ui.datepicker" ], factory );
	} else {

		// Browser globals
		factory( jQuery.datepicker );
	}
}(function( datepicker ) {
	datepicker.regional['hu'] = {
		closeText: 'Bezár',
		prevText: 'Előző',
		nextText: 'Következő',
		currentText: 'Aktuális',
		monthNames: ['január', 'február', 'március', 'április', 'május', 'június',
			'július', 'augusztus', 'szeptember', 'október', 'november', 'december'],
		monthNamesShort: ['jan.', 'feb.', 'márc.', 'ápr.', 'máj.', 'jún.',
			'júl.', 'aug.', 'szept.', 'okt.', 'nov.', 'dec.'],
		dayNames: [ 'vasárnap', 'hétfő', 'kedd', 'szerda', 'csütörtök', 'péntek', 'szombat'],
		dayNamesShort: ['vas.', 'hét.', 'kedd', 'szer.', 'csüt.', 'pén.', 'szom.'],
		dayNamesMin: ['V','H','K','S','C','P','S'],
		weekHeader: 'Hét',
		dateFormat: 'yy.mm.dd',
		firstDay: 1,
		isRTL: false,
		showMonthAfterYear: false,
		yearSuffix: ''};
	datepicker.setDefaults(datepicker.regional['hu']);

	return datepicker.regional['hu'];
}));


