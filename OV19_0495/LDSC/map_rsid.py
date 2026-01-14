import sys

gwas_file = "CAC1000G.ldsc.txt"
rsid_file = "rsid_map_raw.txt"

# Build dictionary from rsid map
rsid_dict = {}
with open(rsid_file) as f:
    for line in f:
        chrom, bp, rsid, ref, alt = line.strip().split("\t")
        rsid_dict[(chrom, bp)] = rsid

out = open("/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/references/ldsc/1000G_with_rsID.txt", "w")
out.write("SNP\tA1\tA2\tBETA\tSE\tP\tN\tCHR\tBP\n")

# Process GWAS file
with open(gwas_file) as f:
    next(f)   # skip header
    for line in f:
        parts = line.strip().split("\t")
        chrom = parts[7]
        bp = parts[8]

        rsid = rsid_dict.get((chrom, bp), ".")
        out.write(
            f"{rsid}\t{parts[1]}\t{parts[2]}\t{parts[3]}\t{parts[4]}\t"
            f"{parts[5]}\t{parts[6]}\t{chrom}\t{bp}\n"
        )

out.close()
