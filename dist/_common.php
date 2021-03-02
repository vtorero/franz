<?php
/**
 * Main DOM <head> section
 *
 *
 * @author     BetterStudio
 * @package    Publisher
 * @version    1.8.4
 */
?>
	<!DOCTYPE html>
	<?php

	ob_start();
	language_attributes();
	$lang_attributes = ob_get_clean();

	?>
	<!--[if IE 8]>
	<html class="ie ie8" <?php echo $lang_attributes; ?>> <![endif]-->
	<!--[if IE 9]>
	<html class="ie ie9" <?php echo $lang_attributes; ?>> <![endif]-->
	<!--[if gt IE 9]><!-->
<html <?php echo $lang_attributes; ?>> <!--<![endif]-->
	<head>
		<?php

		// GTM After <head> code
		if ( publisher_get_option( 'gtm_head' ) ) {
			echo publisher_get_option( 'gtm_head' );
		}

		?>
		<meta charset="<?php bloginfo( 'charset' ); ?>">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="index, follow"/>
    <meta name="GOOGLEBOT" content="index follow"/>
		<link rel="pingback" href="<?php bloginfo( 'pingback_url' ); ?>"/>
    <script type='text/javascript'>
        //Captura variables para DFP desde la url
            var getQueryString = function ( field, url ) {
            var href = url ? url : window.location.href;
            var reg = new RegExp( '[?&]' + field + '=([^&#]*)', 'i' );
            var string = reg.exec(href);
            return string ? string[1] : null;
            };
        dfp_demo = getQueryString("demo");
        </script>
<!-- Start GPT Tag -->
<script async='async' src='https://www.googletagservices.com/tag/js/gpt.js'></script>
<script>
    var gptadslots=[]; var googletag = googletag || {}; googletag.cmd = googletag.cmd || [];
</script>
<script type='text/javascript'>
googletag.cmd.push(function() {  
var mappingtop = googletag.sizeMapping().
addSize([1924, 768], [[468, 60], [728, 90], [970, 90], [970, 250]]).
addSize([980, 600], [[468, 60], [728, 90], [970, 90], [970, 250]]).
addSize([768, 300], [[468, 60], [728, 90]]).
addSize([0, 0], [[320, 100], [320, 50], [300, 250]]).build();
var mappingbox = googletag.sizeMapping().
addSize([1924, 768], [[300, 250], [300, 600]]).
addSize([980, 600], [[300, 250], [300, 600]]).
addSize([768, 300], [[300, 250], [300, 600]]).
addSize([0, 0], [300, 250]).build();
var mappinglateral = googletag.sizeMapping().
addSize([1924, 768], [120, 600]).
addSize([980, 600], [120, 600]).
addSize([0, 0], []).build();
var mappingmbl = googletag.sizeMapping().
addSize([1924, 768], []).
addSize([980 ,600], []).
addSize([0, 0], [[300, 250], [320, 50], [320, 100]]).build();
var mappingsticky = googletag.sizeMapping().
addSize([1924, 768],[728,90]).
addSize([980,600],[728,90]).
addSize([768,300],[728,90]).
addSize([0,0], [[320,100],[320,50]]).build();
googletag.defineSlot('/124027634/cinescape/top1', [[320,100],[320,50],[300,250],[468,60],[728,90],[970,90],[970,250]],'Top1').defineSizeMapping(mappingtop).addService(googletag.pubads());
googletag.defineSlot('/124027634/cinescape/top2', [[320,100],[320,50],[300,250],[468,60],[728,90]],'Top2').defineSizeMapping(mappingtop).addService(googletag.pubads());
googletag.defineSlot('/124027634/cinescape/middle1', [[300,250],[300,600]],'Middle1').defineSizeMapping(mappingbox).addService(googletag.pubads());
googletag.defineSlot('/124027634/cinescape/middle2', [[300,250]], 'Middle2').defineSizeMapping(mappingbox).addService(googletag.pubads());
googletag.defineSlot('/124027634/cinescape/lateral_l', [120, 600],'Lateral_L').defineSizeMapping(mappinglateral).addService(googletag.pubads());
googletag.defineSlot('/124027634/cinescape/lateral_r', [120, 600],'Lateral_R').defineSizeMapping(mappinglateral).addService(googletag.pubads());
googletag.defineSlot('/124027634/cinescape/top3', [[320,100],[320,50],[300,250],[468,60],[728,90]],'Top3').defineSizeMapping(mappingtop).addService(googletag.pubads());
googletag.defineSlot('/124027634/cinescape/center1',[[320,100],[320,50]],'Center1').defineSizeMapping(mappingmbl).addService(googletag.pubads());
googletag.defineSlot('/124027634/cinescape/box1', [300,250],'Box1').defineSizeMapping(mappingbox).addService(googletag.pubads());
googletag.defineSlot('/124027634/cinescape/inread', [1,1],'Inread').addService(googletag.pubads());
googletag.defineSlot('/124027634/cinescape/slider', [[1,2],[1,1]],'Slider').addService(googletag.pubads());
googletag.defineSlot('/124027634/cinescape/zocalo', [1,3],'Zocalo').addService(googletag.pubads());
googletag.defineSlot('/21759101383/Cinescape_Center2',[[320,100],[320, 50]],'Center2').defineSizeMapping(mappingmbl).addService(googletag.pubads());
googletag.defineSlot('/124027634/cinescape/Sticky',[[728,90],[320,100],[320,50]],'ad_sticky').defineSizeMapping(mappingsticky).addService(googletag.pubads());

<?php if(!is_front_page() && !is_category() && !is_page()):?>
googletag.defineSlot('/124027634/cinescape/floating', [1,1],'Floating').addService(googletag.pubads());
<?php endif;?>
<?php global $post;?>
<?php if(wp_is_mobile() && $post->ID !=11316215):?>
googletag.defineOutOfPageSlot('/21759101383/Cinescape_Top_Anchor',googletag.enums.OutOfPageFormat.TOP_ANCHOR).addService(googletag.pubads());
<?php endif;?>
googletag.pubads().setTargeting('Demo',dfp_demo);
<?php global $post;
$url=explode('/',$_SERVER['REQUEST_URI']);
if(is_front_page()) {
print("googletag.pubads().setTargeting('CS_Tipo','Portada');");
print("googletag.pubads().setTargeting('CS_Seccion','');");
}
if(is_category() || is_page() && !is_front_page())
{
print("googletag.pubads().setTargeting('CS_Tipo','Portada');");
print("googletag.pubads().setTargeting('CS_Seccion','".$url[3]."');");
}
if(is_single())
{
  print("googletag.pubads().setTargeting('CS_Tipo','Nota');");
  print("googletag.pubads().setTargeting('CS_Seccion','".$url[2]."');");
  print("googletag.pubads().setTargeting('Nota_CS','".substr($url[3], 0, 39)."');");
}
?>
googletag.pubads().enableSingleRequest();
//googletag.pubads().enableLazyLoad({fetchMarginPercent: 1, renderMarginPercent: 1, mobileScaling: 50.0});
googletag.enableServices();
});
</script>
<!-- End: GPT -->
<?php wp_head(); ?>
<script type="text/javascript" src="wp-content/themes/publisher/js/redirect.js"></script>
<link rel='stylesheet' id='publisher-theme-celebrity-news' href='https://www.americatv.com.pe/cinescape/wp-content/themes/publisher/includes/styles/celebrity-news/style.min.css' type='text/css' media='all'/>
	</head>

<body <?php publisher_attr( 'body' ); ?>>

<?php

// GTM After <body> code
if ( publisher_get_option( 'gtm_body' ) ) {
	echo publisher_get_option( 'gtm_body' );
}
