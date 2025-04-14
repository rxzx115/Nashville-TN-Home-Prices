# Nashville-TN-Home-Prices

Objective: To understand the leading factors that drive home prices in Nashville, TN to guide home construction efforts


Guiding questions:
    - How have average home prices in Nashville, TN grown over year over year?
    - What is the relationship between building values and home prices? What is the relationship between land values and home prices? How strong are these relationships individually?
    - What is the relationship between bedrooms and home prices? What is the relationship between bathrooms and home prices? How strong are these relationships?
    - What is the correlation between the year the home was built and home prices? How strong is the relationship?


Data collection: To retrieve data from Kaggle


Data cleaning:
    - Standardized the address data for data quality 
    - Reviewed outliers to avoid unusual events 
    - Investigated missing values for data usability


Data exploration:
    - Exploratory data analysis was performed in SQL to answer the guiding questions
    - Refer to the separate .sql file for further details


Data visualization
    - Data visualization was performed in Tableau
    - Refer to the separate Tableau data visualization on Tableau Public for further details


Insights and recommendations: 
    1) Building Value and Land Value are Strong Drivers of Home Price. Both building value and land value show strong positive correlations with sale price.
        - Prioritize investments in features that increase building value and target areas with higher land value, including quality finishes, modern amenities, and energy efficiency.
    2) The number of full bathrooms also has a positive correlation to home price.
        - Consider including at least a certain minimum number of full bathrooms in new constructions based on market analysis of buyer preferences. 
    3) The number of bedrooms has a weaker positive correlation when compared to building and land value. 
        - Optimize bedroom count based on target market and property size, without overemphasizing it at the expense of building quality or location.
    4) The median sale price was consistently lower than the average sale price. This difference between the mean and median sale price suggests a right-skewed distribution of home prices, meaning there are likely some higher-priced homes pulling the average up.
        - Consider building a range of housing options to cater to both the typical buyer (reflected by the median price) and the higher-end market (influencing the average price).
