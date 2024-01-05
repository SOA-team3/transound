// Transcipt Download Button
function downloadText(text_type, filename, text_loc) {
  // 獲取 translation 元素
  var translationElement = $(text_loc);

  // 獲取 translation 內容（HTML格式）
  var translationContentHTML = translationElement.html();

  // 將HTML轉換為純文本格式
  var translationContentText = $("<div>").html(translationContentHTML).text();

  // 使用正則表達式插入空行
  var formattedTranslation = translationContentText.replace(/<br>/g, '\n');

  // 創建一個 Blob（二進制大對象）用於存放文字內容
  var blob = new Blob([formattedTranslation], { type: "text/plain" });

  // 創建一個下載連結
  var link = document.createElement("a");

  // 設置 download 屬性，並指定建議的文件名
  link.download = text_type + "_" + filename + ".txt";

  // 創建 Blob 的 URL 並設置為連結的 href 屬性
  link.href = window.URL.createObjectURL(blob);

  // 將連結附加到文檔中
  document.body.appendChild(link);

  // 觸發連結的點擊事件以開始下載
  link.click();

  // 從文檔中移除連結
  document.body.removeChild(link);
}

// Translate Button
$(document).ready(function() {
  // 當按鈕被點擊時
  $("#translateButton").click(function() {
    // 讀取 data-new-content 屬性的值
    var newContent = $(".translate-content .col-md-9").data("new-content");
    // 更改 HTML 內容
    $(".translate-content .col-md-9").html(newContent);
  });
});

// Translate Button
// // 等待文档加载完毕
// $(document).ready(function() {
//   // 当按钮被点击时
//   $("#translateButton").click(function() {
//     // 从下拉菜单中获取所选的值
//     var selectedValue = $("#sel1").val();

//     // 将所选值设置到具有唯一标识符的元素中
//     $("#translationContent").html(selectedValue);
//   });
// });

