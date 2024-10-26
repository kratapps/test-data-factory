module.exports = {
  "**/*.cls": (filenames) =>
    `sf scanner run --engine "pmd" --pmdconfig config/pmd.xml --severity-threshold 3 -t ${filenames.join(
      ",",
    )}`,
};
