#Code book for the getdata-015 course project

Below you will find a brief reference to the original study design and its raw data. Then follows a conceptual walk-through of the data transformations made in this submission and the resulting tidy data set. The third chapter contains information about the variables in this data set. The R script itself is commented in the Readme file also found in this repository.

##1: Study design
Summary of the original study providing the raw data:

The Human Activity Recognition database was built by Smartlab from the recordings of 30 subjects performing activities of daily living while carrying a waist-mounted Android smartphone with embedded inertial sensors. Watch an example here:

[![Activity Recognition Experiment Using Smartphone Sensors](http://img.youtube.com/vi/XOEN9W05_4A/0.jpg)](http://www.youtube.com/watch?v=XOEN9W05_4A) 

The six studied activities are: Walking, Walking Upstairs, Walking Downstairs, Sitting, Standing and Laying down. Using the phone's embedded accelerometer and gyroscope, they captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The obtained dataset was randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. See a full description at http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones# and in the downloadable dataset's readme and info files. 

Original publication:
> Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. A Public Domain Dataset for Human Activity  Recognition Using Smartphones. 21th European Symposium on Artificial Neural Networks, Computational Intelligence and Machine Learning, ESANN 2013. Bruges, Belgium 24-26 April 2013.

##2: Summary choices
The raw data contains a 561-feature vector with measured time and frequency variables, and identifiers for the activity type and the subject who carried out the activity. Our Coursera getdata-015 project assignment was to join these subsets for the training and test data into one dataset, and provide a [tidy](http://vita.had.co.nz/papers/tidy-data.pdf) table containing averages (means) of the relevant measurements per subject, activity and feature/variable. My initial approach based on my SQL background was to deliver this as a "tall" dataset - that is a normalized, molten style. I did that using the plyr (adply) and the reshape2 (melt and acast) packages in R. I ended up with a tidy, narrow set with four columns: SubjectID, ActivityName, FeatureName and AverageMeasuredValue). However, after reading good [discussions](https://class.coursera.org/getdata-015/forum/thread?thread_id=27) in the Coursera forums I ended up switching it to a "wide" data set with as many columns as there are variables, plus identifiers. My main reason for that is that a wide dataset is easier to scan visually for completeness. Now it's easier for you to see that I have the right number of (30*6) rows and the correct variables in my columns. On the other hand, normalized data are typically better prepared for database imports, integrity checks and efficient storage. Usually, the data analysis will need a particular format, so that would normally dictate this choice.

##3: Variable information

###3.1 How the raw data was built
About feature selection, quote from the UCI HAR feature_info file:

>The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

>Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

>Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

>These signals were used to estimate variables of the feature vector for each pattern:  
>'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

>tBodyAcc-XYZ
>tGravityAcc-XYZ
>tBodyAccJerk-XYZ
>tBodyGyro-XYZ
>tBodyGyroJerk-XYZ
>tBodyAccMag
>tGravityAccMag
>tBodyAccJerkMag
>tBodyGyroMag
>tBodyGyroJerkMag
>fBodyAcc-XYZ
>fBodyAccJerk-XYZ
>fBodyGyro-XYZ
>fBodyAccMag
>fBodyAccJerkMag
>fBodyGyroMag
>fBodyGyroJerkMag

>The set of variables that were estimated from these signals are: 

>mean(): Mean value
>std(): Standard deviation
>mad(): Median absolute deviation 
>max(): Largest value in array
>min(): Smallest value in array
>sma(): Signal magnitude area
>energy(): Energy measure. Sum of the squares divided by the number of values. 
>iqr(): Interquartile range 
>entropy(): Signal entropy
>arCoeff(): Autorregresion coefficients with Burg order equal to 4
>correlation(): correlation coefficient between two signals
>maxInds(): index of the frequency component with largest magnitude
>meanFreq(): Weighted average of the frequency components to obtain a mean frequency
>skewness(): skewness of the frequency domain signal 
>kurtosis(): kurtosis of the frequency domain signal 
>bandsEnergy(): Energy of a frequency interval within the 64 bins of the FFT of each window.
>angle(): Angle between two vectors.

>Additional vectors obtained by averaging the signals in a signal window sample. These are used on the angle() variable:

>gravityMean
>tBodyAccMean
>tBodyAccJerkMean
>tBodyGyroMean
>tBodyGyroJerkMean

>The complete list of variables of each feature vector is available in 'features.txt'

The units measured are means of radians per second ([rad/s](https://en.wikipedia.org/wiki/Radian_per_second)) to show rotational speed.

###3.2 What I selected
I initially selected 86 features containing std or mean wording, using R's grep("std|mean") ignoring upper/lower case. But I found that some of these may actually not be standard deviation or means features. For example, the UCI HAR dataset's features_info.txt states this: "meanFreq(): Weighted average of the frequency components to obtain a mean frequency". That's hardly a mean measurement, nor are the angle measurements containing Mean. I ended up choosing what I believe are the only 66 real mean() and std() measurements, using R grep("std\\(\\)|mean\\(\\)). If a fellow student has interpreted this differently, I plan to give lots of leeway as the task wording seems open to more than one interpretation. Variables not needed are easy to filter out at a later stage when it gets clearer which are std/mean and which are not.   

I kept X Y Z elements of the measurements separate in the tidied dataset. Are they really one variable, and therefore should be stored in one column? My reasoning here is that they are separate variables, given that in theory an extremely acrobatic subject could manage to change either X, Y or Z without changing the other two. I also believe the 3D insight from the data could be ruined by merging X, Y and Z. 

In addition to the selected features, two columns were added to identify the motion type (ActivityName) and the subject being observed (SubjectID). This is then the resulting dataset construction:

###3.3 How my tidy.txt looks
tidy.txt, \t tab separated, 180 rows + 1 header row, 68 columns:

1. SubjectID - Chr 1-30 identifying the person performing the activity
2. ActivityName - Chr motion type (LAYING, SITTING, STANDING, WALKING, WALKING_DOWNSTAIRS, WALKING_UPSTAIRS)
3. tBodyAcc-mean()-X - See *Note regarding the rest of the variables below this list
4. tBodyAcc-mean()-Y
5. tBodyAcc-mean()-Z
6. tBodyAcc-std()-X
7. tBodyAcc-std()-Y
8. tBodyAcc-std()-Z
9. tGravityAcc-mean()-X
10. tGravityAcc-mean()-Y
11. tGravityAcc-mean()-Z
12. tGravityAcc-std()-X
13. tGravityAcc-std()-Y
14. tGravityAcc-std()-Z
15. tBodyAccJerk-mean()-X
16. tBodyAccJerk-mean()-Y
17. tBodyAccJerk-mean()-Z
18. tBodyAccJerk-std()-X
19. tBodyAccJerk-std()-Y
20. tBodyAccJerk-std()-Z
21. tBodyGyro-mean()-X
22. tBodyGyro-mean()-Y
23. tBodyGyro-mean()-Z
24. tBodyGyro-std()-X
25. tBodyGyro-std()-Y
26. tBodyGyro-std()-Z
27. tBodyGyroJerk-mean()-X
28. tBodyGyroJerk-mean()-Y
29. tBodyGyroJerk-mean()-Z
30. tBodyGyroJerk-std()-X
31. tBodyGyroJerk-std()-Y
32. tBodyGyroJerk-std()-Z
33. tBodyAccMag-mean()
34. tBodyAccMag-std()
35. tGravityAccMag-mean()
36. tGravityAccMag-std()
37. tBodyAccJerkMag-mean()
38. tBodyAccJerkMag-std()
39. tBodyGyroMag-mean()
40. tBodyGyroMag-std()
41. tBodyGyroJerkMag-mean()
42. tBodyGyroJerkMag-std()
43. fBodyAcc-mean()-X
44. fBodyAcc-mean()-Y
45. fBodyAcc-mean()-Z
46. fBodyAcc-std()-X
47. fBodyAcc-std()-Y
48. fBodyAcc-std()-Z
49. fBodyAccJerk-mean()-X
50. fBodyAccJerk-mean()-Y
51. fBodyAccJerk-mean()-Z
52. fBodyAccJerk-std()-X
53. fBodyAccJerk-std()-Y
54. fBodyAccJerk-std()-Z
55. fBodyGyro-mean()-X
56. fBodyGyro-mean()-Y
57. fBodyGyro-mean()-Z
58. fBodyGyro-std()-X
59. fBodyGyro-std()-Y
60. fBodyGyro-std()-Z
61. fBodyAccMag-mean()
62. fBodyAccMag-std()
63. fBodyBodyAccJerkMag-mean()
64. fBodyBodyAccJerkMag-std()
65. fBodyBodyGyroMag-mean()
66. fBodyBodyGyroMag-std()
67. fBodyBodyGyroJerkMag-mean()
68. fBodyBodyGyroJerkMag-std()

*Note: t and f prefixed features 3:68 are from the time and frequency domain respectively, and their values are normalized numbers within the -1 to +1 range. They are all averages (means) of their measurements per subject and activity. 