// JavaScript Document
$(function() {
   $(".advanced_search").toggle(
        function () {
           $(".submenu").show();
  	 	 $(this).attr('class','advanced_search_expansion advanced_search');
        },
        function () {
           $(".submenu").hide();
  	 	 $(this).attr('class','advanced_search');
        }
      );
   $(".main_area table thead tr th").live( 'mouseover', function(e){     
         $(this).find('.arrow').show();    
   });
   $(".main_area table thead tr th").live('mouseout', function(e) {    
       $(this).find('.arrow').hide();    
   });
  //  $(".arrow").live('click', function(e) {    
  //       $(this).next().show();    
  // });

   $(".bottom_area div").click(function() {
        $(this).addClass("bottom_button_active").removeClass("bottom_button"); 
        $(this).siblings().addClass("bottom_button").removeClass("bottom_button_active");
        var $dangqian = $(".card_frame .frame_element").eq($(".bottom_area div").index(this));
        $dangqian.addClass("card_frame_focus");
        $dangqian.siblings().removeClass("card_frame_focus");
    });

});


function showMe(thisObj,id){
     var objDiv=document.getElementById(id)
     objDiv.style.display=(objDiv.style.display=="none")?'':"none"
     document.onclick=function(e){
        var o = o || window.event || e;
        var obj=o.target || o.srcElement;
        if (obj!=objDiv &&obj!=thisObj)objDiv.style.display='none'
     }
}



