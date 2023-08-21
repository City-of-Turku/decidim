import "src/decidim/geocoding"
import formatAddress from "src/decidim/geocoding/format_address"
console.log("LOADED")
/**
 * For the available address format keys, refer to:
 * https://developer.here.com/documentation/geocoder-autocomplete/dev_guide/topics/resource-type-response-suggest.html
 */
$(() => {
  const generateAddressLabel = formatAddress;

  $("[data-decidim-geocoding]").each((_i, el) => {
    const $input = $(el);
    const config = $input.data("decidim-geocoding");
    const queryMinLength = config.queryMinLength || 2;
    const addressFormat = config.addressFormat || [
      ["street", "houseNumber"],
      "district",
      "city",
      "county",
      "state",
      "country"
    ];
    const language = $("html").attr("lang");
    let currentSuggestionQuery = null;

    if (!config.apiKey || config.apiKey.length < 1) {
      return;
    }

    $input.on("geocoder-suggest.decidim", (_ev, query, callback) => {
      clearTimeout(currentSuggestionQuery);

      // Do not trigger API calls on short queries
      if (`${query}`.trim().length < queryMinLength) {
        return;
      }
      // Changes to the autocomplete based on:
      //https://developer.here.com/documentation/geocoding-search-api/migration_guide/migration-geocoder/topics-api/autocomplete.html
      currentSuggestionQuery = setTimeout(() => {
        $.ajax({
          method: "GET",
          url: "https://autocomplete.search.hereapi.com/v1/autocomplete",
          data: {
            apiKey: config.apiKey,
            q: query,
            lang: language
          },
          dataType: "json"
        }).done((resp) => {
          console.log("The response is:", resp)
          if (resp.items) {
            return callback(resp.items.map((item) => {
              const label = generateAddressLabel(item.address, addressFormat);

              return {
                key: label,
                value: label,
                locationId: item.id
              }
            }));
          }
          return null;
        });
      }, 200);
    });

    $input.on("geocoder-suggest-select.decidim", (_ev, selectedItem) => {
      $.ajax({
        method: "GET",
        url: "https://autocomplete.search.hereapi.com/v1/autocomplete",
        data: {
          apiKey: config.apiKey,
          gen: 9,
          jsonattributes: 1,
          locationid: selectedItem.locationId
        },
        dataType: "json"
      }).done((resp) => {
        if (!resp.response || !Array.isArray(resp.response.view) ||
          resp.response.view.length < 1
        ) {
          return;
        }

        const view = resp.response.view[0];
        if (!Array.isArray(view.result) || view.result.length < 1) {
          return;
        }

        const result = view.result[0];
        const coordinates = [
          result.location.displayPosition.latitude,
          result.location.displayPosition.longitude
        ];

        $input.trigger(
          "geocoder-suggest-coordinates.decidim",
          [coordinates]
        );
      });
    });
  })
})
