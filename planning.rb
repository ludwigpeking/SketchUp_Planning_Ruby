# Main Ruby File
require 'json'
module Planning

  def self.show_define_apartment_dialog
    dialog = UI::HtmlDialog.new({
        :dialog_title => "定义/编辑户型",
        :preferences_key => "ApartmentForm ",
        :scrollable => true,
        :resizable => true,
        :width => 600,
        :height => 400,
        :left => 100,
        :top => 100,
        :style => UI::HtmlDialog::STYLE_DIALOG
    })
      
    html_content = <<-HTML
    <html>
    <head>
      <title>定义/编辑户型</title>
      <meta charset="UTF-8">
    </head>
    <body>
      <h1>定义/编辑户型</h1>
      <input type="button" value="读取现有户型" onclick="loadApt()">
      <input type="button" value="保存" onclick="saveApt()">
      <input type="button" value="另为存" onclick="saveAsNewApt()">
      <form id="apartmentForm">
        面积: <input type="text" id="area_tag" placeholder="120 m²"><br>
        类型: <select id="type_tag">
          <option value="叠拼">叠拼</option>
          <option value="洋房">洋房</option>
          <option value="小高层">小高层</option>
          <option value="大高">大高</option>
          <option value="超高">超高</option>
        </select><br>
        备注T: <input type="text" id="remark_tag" placeholder="备注"><br>
        width 面宽：<input type="text" id="width" placeholder="10.2 m"><br>
        depth 进深：<input type="text" id="depth" placeholder="11.5 m"><br>
        市场需求量价关系表：<br>
        <table>
          <tr>
            <th>单方价格</th>
            <th>月流速（套）</th>
          </tr>
          <tr>
            <td><input type="text" id="price1" placeholder="10000 RMB/m²"></td>
            <td><input type="text" id="flow1" placeholder="10"></td>
          </tr>
          <tr>
            <td><input type="text" id="price2" placeholder="8000 RMB/m²"></td>
            <td><input type="text" id="flow2" placeholder="20"></td>
          </tr>
          <tr>
            <td><input type="text" id="price3" placeholder="6000 RMB/m²"></td>
            <td><input type="text" id="flow3" placeholder="30"></td>
          </tr>
        </table>
        单方成本估值：<input type="text" id="cost" placeholder="5500 RMB/m²"><br>
        得房率：<input type="text" id="ratio" placeholder="0.9"><br>
      </form>
    
      <script>
        function saveApt() {
          // Collect form data
          var areaTag = document.getElementById('area_tag').value;
          var typeTag = document.getElementById('type_tag').value;
          var remark = document.getElementById('remark_tag').value;
          var width = document.getElementById('width').value;
          var depth = document.getElementById('depth').value;
          var price1 = document.getElementById('price1').value;
          var flow1 = document.getElementById('flow1').value;
          var price2 = document.getElementById('price2').value;
          var flow2 = document.getElementById('flow2').value;
          var price3 = document.getElementById('price3').value;
          var flow3 = document.getElementById('flow3').value;
          var constructionCostPerSqm = document.getElementById('cost').value;
          var netAreaRatio = document.getElementById('ratio').value;
          var marketPrediction = [
              {price: price1, flow: flow1},
              {price: price2, flow: flow2},
              {price: price3, flow: flow3}
            ];
          var data = {
            areaTag: areaTag,
            typeTag: typeTag,
            remark: remark,
            width: width,
            depth: depth,
            marketPrediction: marketPrediction,
            constructionCostPerSqm: constructionCostPerSqm,
            netAreaRatio: netAreaRatio
          };
    
          // Send data back to Ruby script
          window.location = 'skp:save_data@' + JSON.stringify(data);
        }
    
        function saveAsNewApt() {
          // Similar to saveApt but with additional logic or a different callback
          // For instance:
          window.location = 'skp:save_as_data@' + JSON.stringify(data);
        }
    
        function loadApt() {
          // Logic to load existing apartment data
          // This could be a call to Ruby to retrieve the data
          window.location = 'skp:load_existing_data';
        }
        function populateForm(data) {
            document.getElementById('area_tag').value = data.areaTag;
            document.getElementById('type_tag').value = data.typeTag;
            document.getElementById('remark_tag').value = data.remark;
            document.getElementById('width').value = data.width;
            document.getElementById('depth').value = data.depth;
            document.getElementById('price1').value = data.marketPrediction[0][0];
            document.getElementById('flow1').value = data.marketPrediction[0][1];
            document.getElementById('price2').value = data.marketPrediction[1][0];
            document.getElementById('flow2').value = data.marketPrediction[1][1];
            document.getElementById('price3').value = data.marketPrediction[2][0];
            document.getElementById('flow3').value = data.marketPrediction[2][1];
            document.getElementById('cost').value = data.constructionCostPerSqm;
            document.getElementById('ratio').value = data.netAreaRatio;
        }

      </script>
    </body>
    </html>
  HTML
    
    dialog.set_html(html_content)
    dialog.show
    
    # Attach a callback to handle the data when the form is submitted
    dialog.add_action_callback("save_data") do |action_context, data|
      parsed_data = JSON.parse(data)
      
      # Define a path to save the data
      file_path = File.join(Sketchup.find_support_file("Plugins"), "apartment_data.json")
      
      # Write data to the file
      File.open(file_path, 'w') do |file|
        file.write(JSON.pretty_generate(parsed_data))
      end
    end

    dialog.add_action_callback("load_existing_data") do |action_context|
      file_path = File.join(Sketchup.find_support_file("Plugins"), "apartment_data.json")
      
      if File.exist?(file_path)
        data = File.read(file_path)
        parsed_data = JSON.parse(data)
        
        # Send the loaded data back to the dialog to populate the form
        script = "populateForm(#{data});"
        dialog.execute_script(script)
      else
        # Handle case where file doesn't exist yet
        puts "Data file doesn't exist yet!"
      end
    end
    

    
  end



  def self.show_define_building_dialog
    dialog = UI::HtmlDialog.new({
      :dialog_title => "定义/编辑楼型（单元）",
      :preferences_key => "BuildingForm",
      :scrollable => true,
      :resizable => true,
      :width => 600,
      :height => 400,
      :left => 100,
      :top => 100,
      :style => UI::HtmlDialog::STYLE_DIALOG
  })
    
    html_content = <<-HTML
    <html>
    <head>
      <title>定义/编辑楼型（单元）</title
          // ... collect other fields ...
    
          // Send data back to Ruby script
          var data = {
            areaTag: areaTag,
            typeTag: typeTag,
            // ... other fields ...
          };
          window.location = 'skp:save_data@' + JSON.stringify(data);
        }
      </script>
    </body>
    </html>
  HTML
      
    dialog.set_html(html_content)
    dialog.show
    
    # Attach a callback to handle the data when the form is submitted
    dialog.add_action_callback("save_data") do |action_context, data|
      parsed_data = JSON.parse(data)

    end
      
  end

  def self.show_define_building_dialog
    dialog = UI::HtmlDialog.new({
      :dialog_title => "定义/编辑楼型（单元）",
      :preferences_key => "BuildingForm",
      :scrollable => true,
      :resizable => true,
      :width => 600,
      :height => 400,
      :left => 100,
      :top => 100,
      :style => UI::HtmlDialog::STYLE_DIALOG
  })
    
    html_content = <<-HTML
    <html>
    <head>
      <title>定义/编辑楼型（单元）</title>
      <meta charset="UTF-8">
      <style>
        .hidden {
          display: none;
        }
        
        .expandable-table {
          border-collapse: collapse;
          width: 100%;
        }
        
        .expandable-table td, .expandable-table th {
          border: 1px solid #dddddd;
          text-align: center;
          padding: 8px;
        }
        
        .expandable-table th {
          background-color: #f2f2f2;
        }
      </style>
    </head>
    <body>
      <input type="button" value="读取现有楼型" onclick="saveForm()">
      <input type="button" value="保存" onclick="saveForm()">
      <input type="button" value="另为存" onclick="saveAsForm()">
    
      <form id="buildingForm">
        <h3>标准层</h3>
        标准层个数：<input type="number" id="standard_layer_count" value="17"><br>
        标准层包含的户型列表:
        <div id="standard_layer_huxing_list">
          <div class="huxing">
            名称：<input type="text" class="name" value="小高120">
            offset:<input type="text" class="offset" value="[0,0]"><br>
          </div>
          <div class="huxing">
            名称：<input type="text" class="name" value="小高120">
            offset:<input type="text" class="offset" value="[10.2,0]"><br>
          </div>
        </div>
        层高：<input type="text" id="standard_layer_height" value="2.9"><br>

        <h3>变异层1</h3>
        变异层个数：<input type="number" id="variant_layer_count" value="1"><br>
        变异层包含的户型:
        <div id="variant_layer_huxing_list">
          <!-- ... similar to the standard_layer_huxing_list ... -->
        </div>
        层高：<input type="text" id="variant_layer_height" value="3.5"><br>

        <!-- Additional variant layers can be added in a similar way -->

        <h3>运营数据</h3>
        开工时间：<input type="date" id="start_date"><br>
        开工到取销售证时间：<input type="number" id="sales_certificate_time" value="6"> 个月<br>
        资金监管金额：<input type="text" id="funds_supervision_amount" value="5000"> RMB<br>
        <!-- ... other HTML content ... -->

        资金监管解活时间：
        <input type="text" id="funds_release_time" value="[0, 0, 0, ...]" onclick="toggleTable('fundsTable')"><br>
        <table id="fundsTable" class="expandable-table hidden">
          
        </table>

        工程付款节奏：
        <input type="text" id="payment_rythm" value="[0.2, 0, 0, ...]" onclick="toggleTable('paymentTable')"><br>
        <table id="paymentTable" class="expandable-table hidden">
          <!-- Structure is similar to the above table -->
        </table>

        <script>
          function toggleTable(tableId) {
            var table = document.getElementById(tableId);
            if (table.classList.contains('hidden')) {
              table.classList.remove('hidden');
            } else {
              table.classList.add('hidden');
            }
          }

          function generateTableContent(tableId) {
            const fundsTable = document.getElementById(tableId);
            for (let year = 1; year <= 5; year++) {
              // Create a new table row for each year
              const row = fundsTable.insertRow();

              // Add the year cell
              const yearCell = row.insertCell();
              yearCell.innerText = `Year ${year}`;

              // Add cells for each of the 12 months
              for (let month = 1; month <= 12; month++) {
                const monthCell = row.insertCell();
                const input = document.createElement('input');
                input.type = 'number';
                input.className = 'month-input';
                input.step = '0.01';
                input.min = '0';
                input.max = '1';
                monthCell.appendChild(input);
              }
            }
          }

          // Call the function to generate the table content
          window.onload = function() {
            generateTableContent('fundsTable');
            generateTableContent('paymentTable');
          }

          // Add listeners to check the sum of the inputs
          // You'll need to add this for both tables
          var monthInputs = document.querySelectorAll('.month-input');
          monthInputs.forEach(function(input) {
            input.addEventListener('input', function() {
              checkTotal();
            });
          });

          function checkTotal() {
            var total = 0;
            monthInputs.forEach(function(input) {
              total += parseFloat(input.value) || 0; // Use the value if it's a number, or 0 if it's not
            });
            if (total !== 1) {
              alert("The sum of all values must be 1!");
            }
          }
        </script>


      </form>

      <script>
      function saveForm() {
        // Example of how to collect form data
        var standardLayerCount = document.getElementById('standard_layer_count').value;
        var standardLayerHeight = document.getElementById('standard_layer_height').value;
        // ... collect data from other fields ...

        // Create an object to send to Ruby
        var data = {
          standardLayerCount: standardLayerCount,
          standardLayerHeight: standardLayerHeight,
          // ... other fields ...
        };

        // Send data back to Ruby script
        window.location = 'skp:save_data@' + JSON.stringify(data);
      }

      function saveAsForm() {
        // Similar to saveForm but with additional logic or a different callback
        // For instance:
        window.location = 'skp:save_as_data@' + JSON.stringify(data);
      }

      function loadExistingBuilding() {
        // Logic to load existing building data
        // This could be a call to Ruby to retrieve the data
        window.location = 'skp:load_existing_data';
      }
    </script>
    </body>
  </html>
  HTML
    
  dialog.set_html(html_content)
  
  # Show the dialog
  dialog.show
  
  # Attach a callback to handle the data when the form is submitted
  dialog.add_action_callback("save_data") do |action_context, data|
    parsed_data = JSON.parse(data)
    # Handle the parsed_data in Ruby
    # For example, save it, create entities in SketchUp, etc.

  end

end

  # ... other UI functions ...



  def self.save_data_to_file(data, path)
    # ... code to save data to a JSON file ...

  end

  def self.load_data_from_file(path)
    # ... code to load data from a JSON file ...
  end


  # =======================
  # Geometric Operations
  # =======================

  def self.place_building_in_model(building_data)
    # ... code to place a building in the SketchUp model based on provided data ...
  end

  # ... other geometric operations ...


  # =======================
  # Callbacks and Event Handlers
  # =======================

  def self.on_save_data_callback(data)
    # ... code to handle data received from a UI dialog ...
  end

  # ... other callbacks ...


  # =======================
  # Initialization and Entry Point
  # =======================

  def self.initialize_plugin
    # Ensure the menu exists
    main_menu = UI.menu("Plugins")
    planning_menu = main_menu.add_submenu("规划测算")
    
    # Now add menu items or toolbar buttons to trigger the above functions
    planning_menu.add_item("定义/编辑户型") { show_define_apartment_dialog }
    planning_menu.add_item("定义/编辑楼型（单元）") { show_define_building_dialog }
    planning_menu.add_item("定义/编辑楼栋") { show_define_building_dialog }
    planning_menu.add_item("查看户型") { show_huxing_dialog }
    # ... other initialization code ...
  end
  
  

  def self.load_huxing_properties_from_file(path)
    JSON.parse(File.read(path))
  end

  def self.generate_huxing_table(huxing_properties)
    table_html = '<table border="1">'
    table_html += '<thead><tr><th>面积Tag</th><th>类型Tag</th><th>备注Tag</th></tr></thead><tbody>'
    
    huxing_properties.each do |property|
      table_html += "<tr>"
      table_html += "<td>#{property['面积Tag']}</td>"
      table_html += "<td>#{property['类型Tag']}</td>"
      table_html += "<td>#{property['备注Tag']}</td>"
      table_html += "</tr>"
    end
  
    table_html += "</tbody></table>"
    table_html
  end

  def self.show_huxing_dialog
    dialog = UI::HtmlDialog.new({:dialog_title => "查看户型", :scrollable => true, :resizable => true, :width => 600, :height => 400})
    
    huxing_properties = load_huxing_properties_from_file("path_to_save_file.json")
    table_html = generate_huxing_table(huxing_properties)
  
    content = <<-HTML
    <html>
    <head>
      <title>查看户型</title>
      <meta charset="UTF-8">
    </head>
    <body>
      #{table_html}
    </body>
    </html>
    HTML
  
    dialog.set_html(content)
    dialog.show
  end
  
  

end

# Call the initialization method when the plugin is loaded
Planning.initialize_plugin
