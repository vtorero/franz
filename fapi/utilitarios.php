<?php
/*
Plugin Name: Utilitarios
Plugin URI: http://google.com
Description: Funciones personalizadas de utilitarios para Caretas 2019
Version: 1.2
Author: Victor Jimenez
Author URI: mailto:vtorero@gmail.com
*/

//Ocultar admin bar a todos los suscriptores
wp_enqueue_script( 'script', get_template_directory_uri() . '/assets/js/play.js', array ( 'jquery' ), 1.1, true);
add_action('after_setup_theme', 'bld_ocultar_admin_bar');
function bld_ocultar_admin_bar() {
if (current_user_can('subscriber')) {
add_filter( 'show_admin_bar', '__return_false' );
}
}

function portada_block(){
    $fps = NelioFPSettings::get_list_of_feat_posts();   
    $post=array_slice($fps,0,1);
    $post2=array_slice($fps,1,6);
    $cat=get_the_category($post[0]->ID,array(750,350));
  $thID = get_post_thumbnail_id($post[0]->ID);
  $img = wp_get_attachment_image_src($thID,'large');
    

  
   $out='<div class="jeg_post jeg_pl_lg_5  post type-post status-publish format-standard has-post-thumbnail hentry">
   <div class="jeg_block_container">
      <div class="jeg_posts_wrap">
   <div class="jeg_postbig">
   <div class="jeg_postblock_content">
<h3 class="jeg_post_title">
    <a href="'.get_permalink($post[0]->ID).'">'.$post[0]->post_title.'</a>
</h3>
</div>
   <div class="jeg_thumb">
    <article class="jeg_post">
        <a href="'.get_permalink($post[0]->ID).'">
<img src="'.$img[0].'" alt="'.$post[0]->post_title.'" class="attachment-jnews-750x375 lazyautosizes data-src="'.$img[0].'" data-sizes="auto" data-srcset="'.$img[0].' 750w, '.$img[0].' 536w, '.$img[0].' 1140w" data-expand="700" sizes="750px" data-srcset="'.$img[0].' 750w, '.$img[0].' 536w, '.$img[0].' 1140w" width="750" height="536">
</a>
<div class="jeg_post_category">
    <span><a href="https://caretas.pe/'.$cat[0]->slug.'/" class="category-nacional">'.$cat[0]->name.'</a></span>
</div>
</div>

</article>
</div>
</div></div>
<!-- top2 -->
<div id="Top2" style="text-align:center;margin-top:10px">
<script>
    googletag.cmd.push(function() { googletag.display("Top2");
    setInterval(function(){googletag.pubads().refresh([gptadslots[2]]);}, 30000); });
</script>
</div>
</div>';
   
$out.='<div class="jeg_postblock_22 jeg_postblock ">
<div class="jeg_block_container">
<div class="jeg_posts_wrap">
<div class="jeg_posts jeg_load_more_flag">';
$count=1;
foreach ($post2 as $post ){
    $cat2=get_the_category($post->ID);
    $thumbID = get_post_thumbnail_id($post->ID);
$imgDestacada = wp_get_attachment_image_src( $thumbID,'medium');

$out.='<article class="jeg_post jeg_pl_md_5 post-'.$post->ID.' post type-post status-publish format-standard has-post-thumbnail">
<div class="jeg_thumb">
    
    <a href="'.get_permalink($post->ID).'"><div class="thumbnail-container animate-lazy  size-715 "><img src="'.$imgDestacada[0].'"  class="attachment-jnews-350x250 size-jnews-350x250 wp-post-image lazyautosizes lazyloaded" alt="'.$post->post_title.'" '.$imgDestacada[0].' 120w" data-expand="700" sizes="230px" data-srcset="'.$imgDestacada[0].' 350w, '.$imgDestacada[0].' 120w" width="350" height="250"></div></a>
    <div class="jeg_post_category">
        <span><a href="https://caretas.pe/'.$cat2[0]->slug.'/" class="category-en-corto">'.$cat2[0]->name.'</a></span>
    </div>
</div>
<div class="jeg_postblock_content">
    <h3 class="jeg_post_title">
        <a href="'.get_permalink($post->ID).'">'.$post->post_title.'</a>
    </h3>
</div>
</article>';

if($count==2 && wp_is_mobile()){

    $out.='';
}

$count++;
}

$out.='</div>
</div>
</div>
</div>';
return $out;
}


function segundo_block(){
    $fps = NelioFPSettings::get_list_of_feat_posts();
    $post1=array_slice($fps,7,3);
    $cat=get_the_category($post[0]->ID,array(750,350));
    $img=get_the_post_thumbnail_url($post[0]->ID,array(750,350));

    $out='<div class="jeg_postblock_10">
                
    <div class="jeg_block_container">
    
    <div class="jeg_posts">';


$nro=1;
foreach ($post1 as $post ){
    $cat2=get_the_category($post->ID,array(750,350));
    $thID = get_post_thumbnail_id($post->ID);
    $img = wp_get_attachment_image_src($thID,'large');
    $img2 = $img[0];

   $out.='<article class="jeg_post jeg_pl_lg_4 post-'.$post->ID.' post type-post status-publish format-standard has-post-thumbnail hentry">
   <header class="jeg_postblock_heading">
   <h3 class="jeg_post_title">
       <a href="'.get_permalink($post->ID).'">'.$post->post_title.'</a>
   </h3>
   </header>
<div class="jeg_postblock_content">
    <div class="jeg_thumb">
        <a href="'.get_permalink($post->ID).'">
        <img width="750" height="375" src="'.$img2.'" class="attachment-jnews-750x375 size-jnews-750x375 wp-post-image lazyautosizes lazyloaded" data-expand="700"></a>
        <div class="jeg_post_category">
            <span><a href="https://caretas.pe/'.$cat2[0]->slug.'/" class="category-deportes">'.$cat2[0]->name.'</a></span>
        </div>
    </div>
    <a href="'.get_permalink($post->ID).'" class="jeg_readmore">Leer más</a>
</div>
   </article>';

   if($nro==2){
       $out.='';
   }
   $nro++;
}

$out.='</div></div></div>';


return $out;
}

function box_1_full_banner2(){
/*desktop box1 -- mobil fullbanner2 HOME*/
$out='';

if(wp_is_mobile()){

    $out.='';


}else{

    $out.='';

}

return $out;

}


function video_player(){
        
    $out='<script>
    jQuery(document).ready(function($) {
            obj.video_detail();
          });
    </script>';

    return $out;
}

function form_impresob(){


  $out='<script>
    jQuery(document).ready(function() {
           jQuery("#enviar").on("click", function (e) {
         e.preventDefault();
   

         jQuery("#txtnombre").css("border", "solid 2px #ccc");
          jQuery("#txtcorreo").css("border", "solid 2px #ccc");
          jQuery("#txtedad").css("border", "solid 2px #ccc");
          jQuery("#txtciudad").css("border", "solid 2px #ccc");
          jQuery("#txtpais").css("border", "solid 2px #ccc");

         var nombres=jQuery.trim(jQuery("#txtnombre").val());
         var correo=jQuery.trim(jQuery("#txtcorreo").val());
         var edad=jQuery.trim(jQuery("#txtedad").val());
         var ciudad=jQuery.trim(jQuery("#txtciudad").val());
         var pais=jQuery.trim(jQuery("#txtpais").val());
         var regex = /[\w-\.]{2,}@([\w-]{2,}\.)*([\w-]{2,}\.)[\w-]{2,4}/;
         

          if(nombres.length <= 2 ) {
                  jQuery("#txtnombre").css("border", "solid 2px #FA5858");
                  return false;
            }

            if(correo.length <= 4) {
             
                     jQuery("#txtcorreo").css("border", "solid 2px #FA5858");
                  return false;
         
                 
            }
            if(edad.length <= 0) {
             
              jQuery("#txtedad").css("border", "solid 2px #FA5858");
           return false;
              
            }

            if(ciudad.length <= 0) {
             
              jQuery("#txtciudad").css("border", "solid 2px #FA5858");
           return false;
              
            }

            if(pais.length <= 0) {
             
              jQuery("#txtpais").css("border", "solid 2px #FA5858");
           return false;
              
            }

              if(!regex.test(correo)){

               alert("Correo invalidado");
                     jQuery("#txtcorreo").css("border", "solid 4px #FA5858");
                  return false;
                  }
        jQuery.post("../wp-content/plugins/utilitarios/impreso.php", { nombre: nombres, correo:correo,edad:edad,ciudad:ciudad,pais:pais,action:"frmimpresos"});

         //jQuery(location).attr("href","https://caretas.pe/caretas-se-queda-en-casa/");
         jQuery(".formulario").html("<a class=\'enlace\' target=\'_blank\' href=\'https://caretas.pe/wp-content/uploads/2020/caretasimpreso.pdf\'> Click aquí para descargar el Archivo </a>");

           });
          });
    </script>';

  $out.='<style>';
  $out.='
.mensaje{
    text-align: center;
    margin-bottom: 30px;
    font-size: 17px;
  }
.formulario label{
display:block;
margin-top: 28px;
}

.formulario input[type=text],
.formulario input[type=email]{
  width:100%;
  border:solid 2px #ccc;
}

.formulario input[type=button]{
    width: 143px;
    margin: 0px auto;
    display: block;
    margin-top: 20px;
    background: black;
    color: white;
    cursor: pointer;
    font-weight: bolder !important;
    border-radius: 29px;
}

.enlace {
    display: block;
    width: 300px;
    margin: 55px auto;
    font-size: 27px;
    text-align: center;
}

  ';
  $out.='</style>';
$out.='<div class="formulario">';
$out.='<form name="impresos2" method="post" accept-charset="utf-8" action="'.esc_url( admin_url('admin-post.php') ).'">';
$out.='<label>Nombres y Apellidos</label>';
$out.='<input type="text" name="nombres" id="txtnombre" placeholder="Ingrese sus nombres y apellidos">';
$out.='<label>Correo</label>';
$out.='<input type="text" name="correo" id="txtcorreo" placeholder="Ingrese su correo">';
$out.='<label>Edad</label>';
$out.='<input type="text" name="edad" id="txtedad" placeholder="Ingrese su edad">';
$out.='<label>Ciudad</label>';
$out.='<input type="text" name="ciudad" id="txtciudad" placeholder="Ingrese su ciudad">';
$out.='<label>País</label>';
$out.='<input type="text" name="pais" id="txtpais" placeholder="Ingrese su país">';
$out.='<input type="hidden" name="action" value="frmimpresos">';
$out.='<input type="button" id="enviar" value="Descargar PDF">';
$out.='</form></div>';  

return $out;
}


function form_impreso(){


  $out='<script>
    jQuery(document).ready(function() {
           jQuery("#enviar").on("click", function (e) {
         e.preventDefault();
   

         jQuery("#txtnombre").css("border", "solid 2px #ccc");
          jQuery("#txtcorreo").css("border", "solid 2px #ccc");
          jQuery("#txtedad").css("border", "solid 2px #ccc");
          jQuery("#txtciudad").css("border", "solid 2px #ccc");
          jQuery("#txtpais").css("border", "solid 2px #ccc");

         var nombres=jQuery.trim(jQuery("#txtnombre").val());
         var correo=jQuery.trim(jQuery("#txtcorreo").val());
         var edad=jQuery.trim(jQuery("#txtedad").val());
         var ciudad=jQuery.trim(jQuery("#txtciudad").val());
         var pais=jQuery.trim(jQuery("#txtpais").val());
         var regex = /[\w-\.]{2,}@([\w-]{2,}\.)*([\w-]{2,}\.)[\w-]{2,4}/;
         

          if(nombres.length <= 2 ) {
                  jQuery("#txtnombre").css("border", "solid 2px #FA5858");
                  return false;
            }

            if(correo.length <= 4) {
             
                     jQuery("#txtcorreo").css("border", "solid 2px #FA5858");
                  return false;
         
                 
            }
            if(edad.length <= 0) {
             
              jQuery("#txtedad").css("border", "solid 2px #FA5858");
           return false;
              
            }

            if(ciudad.length <= 0) {
             
              jQuery("#txtciudad").css("border", "solid 2px #FA5858");
           return false;
              
            }

            if(pais.length <= 0) {
             
              jQuery("#txtpais").css("border", "solid 2px #FA5858");
           return false;
              
            }

              if(!regex.test(correo)){

               alert("Correo invalidado");
                     jQuery("#txtcorreo").css("border", "solid 4px #FA5858");
                  return false;
                  }
                 


        jQuery.post("../wp-content/plugins/utilitarios/impreso.php", { nombre: nombres, correo:correo,action:"frmimpresos"});
        jQuery(location).attr("href","https://caretas.pe/caretas-se-queda-en-casa/");
    

           });
          });
    </script>';

  $out.='<style>';
  $out.='
.mensaje{
    text-align: center;
    margin-bottom: 30px;
    font-size: 17px;
  }
.formulario label{
display:block;
margin-top: 28px;
}

.formulario input[type=text],
.formulario input[type=email]{
  width:100%;
  border:solid 2px #ccc;
}

.formulario input[type=button]{
    width: 143px;
    margin: 0px auto;
    display: block;
    margin-top: 20px;
    background: black;
    color: white;
    cursor: pointer;
    font-weight: bolder !important;
    border-radius: 29px;
}

.enlace {
    display: block;
    width: 300px;
    margin: 55px auto;
    font-size: 27px;
    text-align: center;
}

  ';
  $out.='</style>';


$out.='<div class="formulario">';
$out.='<form name="impresos" method="post" accept-charset="utf-8" action="'.esc_url( admin_url('admin-post.php') ).'">';
$out.='<label>Nombres y Apellidos</label>';
$out.='<input type="text" name="nombres" id="txtnombre" placeholder="Ingrese sus nombres y apellidos">';
$out.='<label>Correo</label>';
$out.='<input type="email" name="correo" id="txtcorreo" placeholder="Ingrese su correo">';
$out.='<label>Edad</label>';
$out.='<input type="text" name="edad" id="txtedad" placeholder="Ingrese su edad">';
$out.='<label>Ciudad</label>';
$out.='<input type="text" name="ciudad" id="txtciudad" placeholder="Ingrese su ciudad">';
$out.='<label>País</label>';
$out.='<input type="text" name="pais" id="txtpais" placeholder="Ingrese su país">';
$out.='<input type="hidden" name="action" value="frmimpresos">';
$out.='<input type="button" id="enviar" value="Acceder">';
$out.='</form></div>';  

return $out;
}


function form_impreso_post(){
global $wpdb;
$wpdb->insert('4kf1w0z_impresos', array(
                        'nombres' => $_POST['nombre'],
                        'correo'  =>   $_POST['correo']
                        )
);


}


add_action('admin_post_nopriv_frmimpresos', 'form_impreso_post'); 
add_action('admin_post_frmimpresos', 'form_impreso_post');
add_shortcode('box1_fullbanner2','box_1_full_banner2'); 
 add_shortcode('codigo','portada_block'); 
 add_shortcode('formimpreso','form_impreso'); 
 add_shortcode('formimpresob','form_impresob'); 
 add_shortcode('videoplayer','video_player'); 
 add_shortcode('segundo','segundo_block'); 