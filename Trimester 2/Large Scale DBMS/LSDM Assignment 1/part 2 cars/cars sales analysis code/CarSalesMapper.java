package gr.aueb.panagiotisl.mapreduce.carsales;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.io.IOException;

public class CarSalesMapper extends Mapper<LongWritable, Text, Text, Text> {

    private static final SimpleDateFormat INPUT_DATE_FORMAT = new SimpleDateFormat("EEE MMM dd yyyy HH:mm:ss 'GMT'Z (z)");
    private static final SimpleDateFormat OUTPUT_DATE_FORMAT = new SimpleDateFormat("yyyy-MM");

    @Override
    public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        String line = value.toString().trim();

        // Skip header line
        if (key.get() == 0 && line.startsWith("year,make,model")) {
            return;
        }

        // Proper CSV splitting
        String[] fields = line.split(",");
        if (fields.length < 16) {
            System.out.println("Skipping malformed line: " + line);
            return;
        }

        try {
            String make = fields[1].trim();
            String model = fields[2].trim();
            String trim = fields[3].trim();
            String seller = fields[12].trim();
            String mmrStr = fields[13].trim();
            String sellingPriceStr = fields[14].trim();
            String dateStr = fields[15].trim();

            // Ensure required fields are not empty
            if (make.isEmpty() || model.isEmpty() || trim.isEmpty() || seller.isEmpty() || mmrStr.isEmpty() || sellingPriceStr.isEmpty()) {
                System.out.println("Skipping row due to missing values: " + line);
                return;
            }

            Date date = INPUT_DATE_FORMAT.parse(dateStr);
            String monthYear = OUTPUT_DATE_FORMAT.format(date); // yyyy-MM format

            double sellingPrice = Double.parseDouble(sellingPriceStr);
            double mmr = Double.parseDouble(mmrStr);
            double difference = sellingPrice - mmr;

            String carModelTrim = make + " " + model + " " + trim;

            // Ensure carModelTrim is meaningful
            if (carModelTrim.replaceAll("\\s+", "").isEmpty()) {
                System.out.println("Skipping row due to empty car model: " + line);
                return;
            }

            context.write(new Text(seller + ":" + monthYear), new Text(carModelTrim + ":" + difference));
        } catch (Exception e) {
            System.out.println("Error processing line: " + line + " | " + e.getMessage());
        }
    }
}
