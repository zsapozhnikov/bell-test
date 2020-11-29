<?php

namespace App\Controller;

use App\Service\BookSearchService;
use Symfony\Component\HttpFoundation\RequestStack;

class BookSearch
{
    private $bookSearchService;
    private $requestStack;

    public function __construct(BookSearchService $bookSearchService, RequestStack $requestStack)
    {
        $this->bookSearchService = $bookSearchService;
        $this->requestStack = $requestStack;
    }

    public function __invoke()
    {
        $book = $this->bookSearchService->handle($this->requestStack->getCurrentRequest()->get('query', ''));

        return $book;
    }
}