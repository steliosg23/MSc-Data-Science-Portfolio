package gr.aueb.panagiotisl.mapreduce.carsales;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;

public class CarSalesDriver {

    public static void main(String[] args) throws Exception {

        // Default paths if no arguments are passed
        String inputPath = "/user/hdfs/input/cars.csv";
        String outputPath = "/user/hdfs/output/";

        // If arguments are provided, override default paths
        if (args.length == 2) {
            inputPath = args[0];
            outputPath = args[1];
        } else {
            System.out.println("No arguments passed. Using default paths:");
            System.out.println("Input Path: " + inputPath);
            System.out.println("Output Path: " + outputPath);
        }

        Configuration conf = new Configuration();
        FileSystem fs = FileSystem.get(conf);

        // Check if output path exists and delete it
        Path outputDir = new Path(outputPath);
        if (fs.exists(outputDir)) {
            fs.delete(outputDir, true);
            System.out.println("Deleted existing output directory: " + outputPath);
        }

        // Set up the Hadoop job
        Job job = Job.getInstance(conf, "Car Sales Analysis");

        job.setJarByClass(CarSalesDriver.class);
        job.setMapperClass(CarSalesMapper.class);
        job.setReducerClass(CarSalesReducer.class);

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(Text.class);
        job.setInputFormatClass(TextInputFormat.class);

        FileInputFormat.addInputPath(job, new Path(inputPath));
        FileOutputFormat.setOutputPath(job, outputDir);

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
