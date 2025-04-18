% Define grid size and gray color
gridSize = 7; % 7x7 grid
grayColor = 0.5; % Color for gray squares (0=black, 1=white)

% Define all six patterns
patterns = {
    [ % Full-Point
        1 1 1 1 1 1 1;
        1 1 1 1 1 1 1;
        1 1 1 1 1 1 1;
        1 1 1 0 1 1 1;
        1 1 1 1 1 1 1;
        1 1 1 1 1 1 1;
        1 1 1 1 1 1 1;
    ],
    [ % Non-Redundant
        1 0 1 0 1 0 1;
        0 1 0 1 0 1 0;
        1 0 1 0 1 0 1;
        0 1 0 0 1 0 1;
        0 1 0 1 0 1 0;
        1 0 1 0 1 0 1;
        0 1 0 1 0 1 0;
    ],
    [ % Uniform
        0 1 0 1 0 1 0;
        1 0 1 0 1 0 1;
        0 1 0 1 0 1 0;
        1 0 1 0 1 0 1;
        0 1 0 1 0 1 0;
        1 0 1 0 1 0 1;
        0 1 0 1 0 1 0;
    ],
    [ % 16-Point
        0 0 0 1 0 0 0;
        0 0 1 0 1 0 0;
        0 1 0 0 0 1 0;
        1 0 0 0 0 0 1;
        0 1 0 0 0 1 0;
        0 0 1 0 1 0 0;
        0 0 0 1 0 0 0;
    ],
    [ % 12-Point
        0 0 0 0 0 0 0;
        0 0 1 1 1 0 0;
        0 1 0 0 0 1 0;
        0 1 0 0 0 1 0;
        0 1 0 0 0 1 0;
        0 0 1 1 1 0 0;
        0 0 0 0 0 0 0;
    ],
    [ % 8-Point
        0 0 0 0 0 0 0;
        0 1 0 1 0 1 0;
        0 0 0 0 0 0 0;
        0 1 0 0 0 1 0;
        0 0 0 0 0 0 0;
        0 1 0 1 0 1 0;
        0 0 0 0 0 0 0;
    ],
    [ % 4-Point
        0 0 0 0 0 0 0;
        0 0 0 1 0 0 0;
        0 0 0 0 0 0 0;
        0 1 0 0 0 1 0;
        0 0 0 0 0 0 0;
        0 0 0 1 0 0 0;
        0 0 0 0 0 0 0;
    ],
    [ % 2-Point
        0 0 0 0 0 0 0;
        0 0 0 0 0 0 0;
        0 0 0 0 0 0 0;
        0 1 0 0 0 1 0;
        0 0 0 0 0 0 0;
        0 0 0 0 0 0 0;
        0 0 0 0 0 0 0;
    ],
    [ % 1-Point
        0 0 0 0 0 0 0;
        0 0 0 0 0 0 0;
        0 0 0 0 0 0 0;
        0 1 0 0 0 0 0;
        0 0 0 0 0 0 0;
        0 0 0 0 0 0 0;
        0 0 0 0 0 0 0;
    ]
};

names ={'Full', 'Non-Redundant', 'Uniform', '16-Point', '12-Point', '8-Point', '4-Point', '2-Point', '1-Point'};
% Plot all six patterns in a 2x3 grid
figure;
for i = 1:9
    subplot(3, 3, i); % Arrange in 2 rows, 3 columns
    imagesc(patterns{i}); % Display the pattern matrix
    colormap([1 1 1; grayColor grayColor grayColor]); % White and gray
    axis equal; % Keep grid squares equal in size
    axis([0.5 gridSize+0.5 0.5 gridSize+0.5]); % Adjust axis limits
    xticks(0.5:1:gridSize+0.5); % Set x-tick positions for grid
    yticks(0.5:1:gridSize+0.5); % Set y-tick positions for grid
    grid on; % Enable grid
    set(gca, 'GridColor', 'k', 'GridAlpha', 0.5); % Black gridlines with transparency
    set(gca, 'XTickLabel', [], 'YTickLabel', []); % Remove axis labels
    title(names{i}); % Titles (16-Point, 12-Point, etc.)
end
