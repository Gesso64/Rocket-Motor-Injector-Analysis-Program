classdef Rocket_Motor_Injector_Analysis < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        MaxFlowRateEditField        matlab.ui.control.NumericEditField
        MassFlowRateLimitLabel      matlab.ui.control.Label
        KgsLabel                    matlab.ui.control.Label
        RocketMotorInjectorAnalysisLabel  matlab.ui.control.Label
        PaLabel                     matlab.ui.control.Label
        KgM3Label                   matlab.ui.control.Label
        PressureDropEditField       matlab.ui.control.NumericEditField
        PressureDropEditFieldLabel  matlab.ui.control.Label
        DensityEditField            matlab.ui.control.NumericEditField
        DensityLabel                matlab.ui.control.Label
        MassFlowRateValue           matlab.ui.control.Label
        MassFlowRateSlider          matlab.ui.control.Slider
        MassFlowRatekgsLabel        matlab.ui.control.Label
        CalculateButton             matlab.ui.control.StateButton
        UITable                     matlab.ui.control.Table
        UIAxes                      matlab.ui.control.UIAxes
    end

    
    methods (Access = private)
        
 function plotData(app, mass_flow_rate)
            % Get the density and pressure drop values from the input fields
            density = app.DensityEditField.Value; 
            pressure_drop = app.PressureDropEditField.Value;

            % Range of discharge coefficients
            Cd_values = 0.5:0.05:1.0;

            % Calculate the area, diameter, radius, and diameter in inches for each Cd
            areas = zeros(size(Cd_values));
            diameters = zeros(size(Cd_values));
            radii = zeros(size(Cd_values));
            diameters_in_inches = zeros(size(Cd_values));

            for i = 1:length(Cd_values)
                Cd = Cd_values(i);
                area = mass_flow_rate / (Cd * sqrt(2 * density * pressure_drop));
                areas(i) = area;
                diameter = sqrt(4 * area / pi) * 1000; % Convert to mm
                diameters(i) = diameter;
                radii(i) = diameter / 2; % Calculate radius in mm
                diameters_in_inches(i) = diameter / 25.4; % Convert diameter to inches
            end

            % Plot data
            plot(app.UIAxes, diameters, Cd_values, 'o-');
            title(app.UIAxes, 'Orifice Diameter vs. Discharge Coefficient');
            xlabel(app.UIAxes, 'Orifice Diameter (mm)');
            ylabel(app.UIAxes, 'Discharge Coefficient (Cd)');
            grid(app.UIAxes, 'on');

            % Update table data
            data = table(Cd_values', areas', diameters', radii', diameters_in_inches', ...
                         'VariableNames', {'Cd', 'Area_m2', 'Diameter_mm', 'Radius_mm', 'Diameter_in'});
            app.UITable.Data = data;
        end

        function updatePlot(app)
            new_mass_flow_rate = app.MassFlowRateSlider.Value;
            app.MassFlowRateValue.Text = num2str(new_mass_flow_rate);
            plotData(app, new_mass_flow_rate);
        end
        
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Initial plot with default mass flow rate
            initial_mass_flow_rate = 0.001132;
            app.MassFlowRateSlider.Value = initial_mass_flow_rate;
            app.SliderValue.Text = num2str(initial_mass_flow_rate);
            plotData(app, initial_mass_flow_rate);
        end

        % Button pushed function: Button
        function ButtonPushed(app, ~)
            updatePlot(app);
        end

        % Value changing function: Slider
        function SliderValueChanged(app, event)
            new_mass_flow_rate = event.Value;
            app.MassFlowRateValue.Text = num2str(new_mass_flow_rate);
            plotData(app, new_mass_flow_rate);
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: CalculateButton
        function CalculateButtonValueChanged(app, event)
            updatePlot(app);
            
        end

        % Value changing function: MassFlowRateSlider
        function MassFlowRateSliderValueChanging(app, event)
            new_mass_flow_rate = event.Value;
            app.MassFlowRateValue.Text = num2str(new_mass_flow_rate);
            plotData(app, new_mass_flow_rate);
        end

        % Value changed function: MaxFlowRateEditField
        function MaxFlowRateEditFieldValueChanged2(app, event)
        max_flow_rate = app.MaxFlowRateEditField.Value;
        app.MassFlowRateSlider.Limits = [0 max_flow_rate];
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.251 0.2706 0.3216];
            app.UIFigure.Position = [100 100 1507 969];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Scrollable = 'on';
            app.UIFigure.WindowState = 'maximized';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Discharge Coefficient vs. Oriface Diameter')
            xlabel(app.UIAxes, 'Oriface Diameter (mm)')
            ylabel(app.UIAxes, 'Discharge Coefficient (Cd)')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Color = [0 0.4471 0.7412];
            app.UIAxes.GridColor = [0.9412 0.9412 0.9412];
            app.UIAxes.ColorOrder = [0.635294117647059 0.0784313725490196 0.184313725490196;0.850980392156863 0.325490196078431 0.0980392156862745;0.929411764705882 0.694117647058824 0.125490196078431;0.494117647058824 0.184313725490196 0.556862745098039;0.466666666666667 0.674509803921569 0.188235294117647;0.301960784313725 0.745098039215686 0.933333333333333;0.635294117647059 0.0784313725490196 0.184313725490196];
            app.UIAxes.FontSize = 14;
            app.UIAxes.Position = [644 70 804 771];

            % Create UITable
            app.UITable = uitable(app.UIFigure);
            app.UITable.BackgroundColor = [0 0.4471 0.7412;0 0.451 0.7412];
            app.UITable.ColumnName = {'Cd'; 'Area (m^2)'; 'Diameter (mm)'; 'Radius(mm)'; 'Diameter (in)'};
            app.UITable.RowName = {};
            app.UITable.FontSize = 14;
            app.UITable.Position = [46 254 589 257];

            % Create CalculateButton
            app.CalculateButton = uibutton(app.UIFigure, 'state');
            app.CalculateButton.ValueChangedFcn = createCallbackFcn(app, @CalculateButtonValueChanged, true);
            app.CalculateButton.Text = 'Calculate';
            app.CalculateButton.BackgroundColor = [0 0.4471 0.7412];
            app.CalculateButton.Position = [446 547 122 26];

            % Create MassFlowRatekgsLabel
            app.MassFlowRatekgsLabel = uilabel(app.UIFigure);
            app.MassFlowRatekgsLabel.WordWrap = 'on';
            app.MassFlowRatekgsLabel.FontSize = 14;
            app.MassFlowRatekgsLabel.FontWeight = 'bold';
            app.MassFlowRatekgsLabel.Position = [443 819 191 60];
            app.MassFlowRatekgsLabel.Text = 'Mass Flow Rate (kg/s)';

            % Create MassFlowRateSlider
            app.MassFlowRateSlider = uislider(app.UIFigure);
            app.MassFlowRateSlider.Limits = [0 0.0025];
            app.MassFlowRateSlider.Orientation = 'vertical';
            app.MassFlowRateSlider.ValueChangingFcn = createCallbackFcn(app, @MassFlowRateSliderValueChanging, true);
            app.MassFlowRateSlider.Position = [443 653 42 156];
            app.MassFlowRateSlider.Value = 0.001132;

            % Create MassFlowRateValue
            app.MassFlowRateValue = uilabel(app.UIFigure);
            app.MassFlowRateValue.WordWrap = 'on';
            app.MassFlowRateValue.FontSize = 14;
            app.MassFlowRateValue.Position = [447 597 105 22];
            app.MassFlowRateValue.Text = 'initial';

            % Create DensityLabel
            app.DensityLabel = uilabel(app.UIFigure);
            app.DensityLabel.HorizontalAlignment = 'right';
            app.DensityLabel.FontSize = 14;
            app.DensityLabel.FontWeight = 'bold';
            app.DensityLabel.Position = [68 841 56 22];
            app.DensityLabel.Text = 'Density';

            % Create DensityEditField
            app.DensityEditField = uieditfield(app.UIFigure, 'numeric');
            app.DensityEditField.FontSize = 14;
            app.DensityEditField.BackgroundColor = [0 0.4471 0.7412];
            app.DensityEditField.Position = [136 835 179 33];
            app.DensityEditField.Value = 1.331;

            % Create PressureDropEditFieldLabel
            app.PressureDropEditFieldLabel = uilabel(app.UIFigure);
            app.PressureDropEditFieldLabel.HorizontalAlignment = 'right';
            app.PressureDropEditFieldLabel.FontSize = 14;
            app.PressureDropEditFieldLabel.FontWeight = 'bold';
            app.PressureDropEditFieldLabel.Position = [19 764 101 22];
            app.PressureDropEditFieldLabel.Text = 'Pressure Drop';

            % Create PressureDropEditField
            app.PressureDropEditField = uieditfield(app.UIFigure, 'numeric');
            app.PressureDropEditField.FontSize = 14;
            app.PressureDropEditField.BackgroundColor = [0 0.4471 0.7412];
            app.PressureDropEditField.Position = [135 752 179 46];
            app.PressureDropEditField.Value = 965266.4;

            % Create KgM3Label
            app.KgM3Label = uilabel(app.UIFigure);
            app.KgM3Label.FontSize = 14;
            app.KgM3Label.Position = [326 831 53 35];
            app.KgM3Label.Text = 'Kg/M^3';

            % Create PaLabel
            app.PaLabel = uilabel(app.UIFigure);
            app.PaLabel.FontSize = 14;
            app.PaLabel.Position = [326 757 29 35];
            app.PaLabel.Text = 'Pa';

            % Create RocketMotorInjectorAnalysisLabel
            app.RocketMotorInjectorAnalysisLabel = uilabel(app.UIFigure);
            app.RocketMotorInjectorAnalysisLabel.HorizontalAlignment = 'center';
            app.RocketMotorInjectorAnalysisLabel.FontSize = 24;
            app.RocketMotorInjectorAnalysisLabel.FontWeight = 'bold';
            app.RocketMotorInjectorAnalysisLabel.Position = [46 893 1415 46];
            app.RocketMotorInjectorAnalysisLabel.Text = 'Rocket Motor Injector Analysis';

            % Create KgsLabel
            app.KgsLabel = uilabel(app.UIFigure);
            app.KgsLabel.FontSize = 14;
            app.KgsLabel.Position = [326 658 33 35];
            app.KgsLabel.Text = 'Kg/s';

            % Create MassFlowRateLimitLabel
            app.MassFlowRateLimitLabel = uilabel(app.UIFigure);
            app.MassFlowRateLimitLabel.HorizontalAlignment = 'right';
            app.MassFlowRateLimitLabel.WordWrap = 'on';
            app.MassFlowRateLimitLabel.FontSize = 14;
            app.MassFlowRateLimitLabel.FontWeight = 'bold';
            app.MassFlowRateLimitLabel.Position = [13 641 110 69];
            app.MassFlowRateLimitLabel.Text = 'Mass Flow Rate Limit';

            % Create MaxFlowRateEditField
            app.MaxFlowRateEditField = uieditfield(app.UIFigure, 'numeric');
            app.MaxFlowRateEditField.ValueChangedFcn = createCallbackFcn(app, @MaxFlowRateEditFieldValueChanged2, true);
            app.MaxFlowRateEditField.FontSize = 14;
            app.MaxFlowRateEditField.BackgroundColor = [0 0.4471 0.7412];
            app.MaxFlowRateEditField.Position = [135 653 179 46];
            app.MaxFlowRateEditField.Value = 0.001132;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Rocket_Motor_Injector_Analysis

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end