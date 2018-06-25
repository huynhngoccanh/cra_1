// $(function() {     

//     var image_thumb_article = [];
//     console.log ("haaaaaaaaaaaaaaaaaaaa")
//     var avaliable_article_ids = [0,1,2,3];
//     var upload_button_article = document.getElementsByClassName("upload-button-article")[0];
    
//     var collected_media_article = document.getElementById("media");
//     var collected_article_url = {};
//     image_thumb_article[0] = document.getElementsByClassName("image-thumb-article-1");
//     console.log("a",image_thumb_article[0]);
//     image_thumb_article[1] = document.getElementById("image-thumb-article-2");
//     image_thumb_article[2] = document.getElementById("image-thumb-article-3");
//     image_thumb_article[3] = document.getElementById("image-thumb-article-4");
//     var video_thumb_article = document.getElementById("video-thumb-article");   
//     for (var i=0;i<image_thumb_article[0].length; i++) {
//         console.log("b");
//       image_thumb_article[0][i].style.display = 'none';
//     }
//     // for (i = 1; i < 4; i++) {
//     //   image_thumb_article[i].style.display = 'none';
//     // }
//     // video_thumb_article.style.display = 'none';
//     var index = 0;
//     if(collected_media_article){
//       if (collected_media_article.value){
        
  
//         var url_object = JSON.parse(collected_media_article.value);
       
//           for(var i in url_object) {
            
//             if (url_object.hasOwnProperty(i)) {
              
//                 if ((url_object[i].url.indexOf(".jpg") > -1) || (url_object[i].url.indexOf(".png") > -1)) {
               
//                   image_thumb_article[index].src =  url_object[i].thumb_url;
//                   index ++;
//                 } else {
//                   video_thumb_article.src = url_object[i].url;
//                   video_thumb_article.style.display = 'inline';
//                 }
//               }
//           }
//       }
//     }

    
//     // for(var i = index; i < 4; i++){
//     //   image_thumb_article[i].style.display = "none";
//     // }
   

//     upload_button_article.addEventListener("click", function() {
//           if(avaliable_article_ids.length == 0){
//               window.alert("Sorry,You have exceeded your max attach limit");
//           } else {
         
//             cloudinary.openUploadWidget({ cloud_name: 'hqps4ipsj', cropping : 'server', multiple: true,  upload_preset: 'czardom',return_delete_token:true}, 
//               function(error, result) {
//                 console.log(result);
//                 if(!error){
                  
//                   if(avaliable_article_ids.length > 0){
                    
//                     if(result[0].resource_type == "video") {
                     
//                       video_thumb_article.src = result[0].url;
//                       video_thumb_article.style.display = 'inline';
//                       collected_article_url["4"] = {
//                         url : result[0].url,
//                         thumb_url: result[0].url
//                       };        
//                       video_thumb_article.addEventListener('dblclick', function(){ 
                        
//                         // remove item
//                         video_thumb_article.src = null;
//                         video_thumb_article.style.display = "none";
//                         delete collected_article_url["4"];
//                         collected_media_article.value = JSON.stringify(collected_article_url);
                        
//                       });
//                     } else {
//                       var index = avaliable_article_ids[0];
//                       image_thumb_article[index].src = result[0].thumbnail_url;
//                       image_thumb_article[index].style.display = 'inline';
                      
//                       image_thumb_article[index].addEventListener('dblclick', function(){ 

//                         delete collected_article_url[index];
//                         avaliable_article_ids.unshift(index);
                      
//                         collected_media_article.value = JSON.stringify(collected_article_url);
//                         image_thumb_article[index].src = null;
//                         image_thumb_article[index].style.display = "none";
//                       });
                      
//                       collected_article_url[index] = {
//                         url : result[0].url,
//                         thumb_url: result[0].thumbnail_url
//                       };
//                       avaliable_article_ids.shift();
                      
//                     //  window.alert(collected_media_article.value);
//                     }
                    
                    
//                   collected_media_article.value = JSON.stringify(collected_article_url);
//                   } else {
//                     window.alert("max attach limit excceded");
//                   }
//                 }
//               });     
//           }
//       }, false);     
// });