package gr.aueb.panagiotisl.mapreduce.carsales;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class CarSalesReducer extends Reducer<Text, Text, Text, Text> {

    @Override
    public void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
        List<Double> differences = new ArrayList<>();
        String maxCar = "No valid data found";
        double maxDifference = Double.NEGATIVE_INFINITY;

        for (Text val : values) {
            String[] parts = val.toString().split(":");
            if (parts.length == 2) {
                String carModelTrim = parts[0].trim();
                double difference = Double.parseDouble(parts[1].trim());

                // Find the car with the largest price difference
                if (difference > maxDifference) {
                    maxDifference = difference;
                    maxCar = carModelTrim;
                }

                differences.add(difference);
            }
        }

        // Calculate the average price difference
        double avgDifference = differences.isEmpty() ? 0 : differences.stream().mapToDouble(Double::doubleValue).average().orElse(0.0);

        // Properly formatted output: "carModel: maxDifference, avg: avgDifference"
        if (!differences.isEmpty()) {
            String result = maxCar + ": " + String.format("%.1f", maxDifference) + ", avg: " + String.format("%.1f", avgDifference);
            context.write(key, new Text(result));
        } else {
            context.write(key, new Text("No valid data found"));
        }
    }
}
